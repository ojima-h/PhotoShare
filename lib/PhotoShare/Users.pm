package PhotoShare::Users;
use Mojo::Base 'Mojolicious::Controller';

sub create {
  my $self = shift;
  my $token = $self->param('token');
  my $signup_info = $self->session('signup_info');

  unless (defined $signup_info) {
    $self->flash('alert-error' => "セッションの有効期限が切れています");
    return $self->redirect_to('/signup');
  }

  unless ($signup_info->{token} eq $token) {
    $self->flash('alert-error' => "無効なセッションです");
    return $self->redirect_to('/signup');
  }

  my $user = $self->model->User->create(
    name     => $signup_info->{name},
    email    => $signup_info->{email},
    password => $signup_info->{password},
  );

  if ($user) {
    $self->authenticate($signup_info->{name}, $signup_info->{password});
    delete $self->session->{signup_info};

    $self->flash('alert-success' => 'ユーザ登録が完了しました');
    $self->redirect_to('/');
  } else {
    $self->flash('alert-error' => 'ユーザ登録に失敗しました');
    $self->redirect_to('/signup');
  }
}

1;
