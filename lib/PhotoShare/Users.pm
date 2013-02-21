package PhotoShare::Users;
use Mojo::Base 'Mojolicious::Controller';

sub create {
  my $self = shift;

  if ($self->param('password') eq $self->param('password-confirm')) {
    my $user = $self->model->User->create($self->param(['name', 'email', 'password']));

    if ($user) {
      $self->flash('alert-success' => 'ユーザ登録が完了しました');
      $self->redirect_to('/login');
    } else {
      $self->flash('alert-error' => 'ユーザ登録に失敗しました');
      $self->redirect_to('/signup');
    }
  } else {
    $self->flash('alert-error' => 'パスワードが一致しません');
    $self->redirect_to('/signup');
  }
}

1;
