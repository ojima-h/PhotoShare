package PhotoShare;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Protection from CSRF attack.
  $self->plugin('CSRFProtect');

  # User Authentication
  $self->plugin('authentication' => {
    'autoload_user' => 1,
    'session_key' => 'wickedapp',
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

1;
