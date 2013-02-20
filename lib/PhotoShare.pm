package PhotoShare;
use Mojo::Base 'Mojolicious';

use PhotoShare::Config;

# This method will run once at server start
sub startup {
  my $self = shift;

  PhotoShare::Config->load($self);

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Protection from CSRF attack.
  $self->plugin('CSRFProtect');

  $self->helper(db => sub { dbconnection($self->config->{db})});

  # User Authentication
  $self->plugin('authentication' => {
    'autoload_user' => 1,
    'session_key' => $self->config->{session_key},
    'load_user' => sub {
      my ($app, $uid) = @_;
      return { uid => $uid }
    },
    'validate_user' => sub {
      my ($app, $name, $password, $extradata) = @_;
      if ( $name eq 'foo' and $password eq 'bar' ) {
        return $name;
      } else {
        return undef;
      }
    },
  });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # Login / Logout
  $r->get('/login')->to('login#form');
  $r->post('/sessions')->to('sessions#create');
  $r->get('/logout')->to('sessions#destroy');
}

sub dbconnection {
  my $dbconf = shift;

  Library::Schema->connect(
    $dbconf->{dsn},
    $dbconf->{user},
    $dbconf->{password},
    { AutoCommit => 1 },
  );
}

1;
