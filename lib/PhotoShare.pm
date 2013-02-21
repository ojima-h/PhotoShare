package PhotoShare;
use Mojo::Base 'Mojolicious';

use PhotoShare::Config;
use PhotoShareModel::Schema;

# This method will run once at server start
sub startup {
  my $self = shift;

  PhotoShare::Config->load($self);

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Protection from CSRF attack.
  $self->plugin('CSRFProtect');

  $self->helper(db => sub { $self->dbconnection });

  # User Authentication
  $self->plugin('authentication' => {
    'autoload_user' => 1,
    'session_key' => $self->config->{session_key},
    'load_user' => sub {
      my ($app, $uid) = @_;
      return $app->db->resultset('User')->find($uid);
    },
    'validate_user' => sub {
      my ($app, $name, $password, $extradata) = @_;

      my $user = $app->db->resultset('User')->search({
        name => $name,
        password => $password})->first;

      if ($user) {
        return $user->id;
      } else {
        return undef
      }
    },
  });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # Sign Up
  $r->get('/signup')->to('signup#form');
  $r->post('/users')->to('users#create');

  # Login / Logout
  $r->get('/login')->to('login#form');
  $r->post('/sessions')->to('sessions#create');
  $r->get('/logout')->to('sessions#destroy');
}

sub dbconnection {
  my $self = shift;
  my ($dsn, $user, $password) = @{ $self->config->{db} };
  PhotoShareModel::Schema->connect(
    $dsn,
    $user,
    $password,
    { AutoCommit => 1 },
  );
}

1;
