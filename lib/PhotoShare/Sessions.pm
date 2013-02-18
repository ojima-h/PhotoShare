package PhotoShare::Sessions;
use Mojo::Base 'Mojolicious::Controller';

sub create {
  my $self = shift;

  my $name = $self->param('name');
  my $password = $self->param('password');

  if ( $self->authenticate($name, $password) ) {
    $self->redirect_to('/');
  } else {
    $self->flash(message => 'ユーザ名またはパスワードが間違っています');
    $self->redirect_to('/login');
  }
}

sub destroy {
  my $self = shift;

  $self->flash(message => 'ログアウトしました');
  $self->logout;
  $self->redirect_to('/login');
}

1;
