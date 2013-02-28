package PhotoShare;
use Mojo::Base 'Mojolicious';

use PhotoShareModel;
use PhotoShareModel::Schema;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Initialize PhotoShareModel
  my $model = PhotoShareModel->new($self->mode);
  $self->helper(model => sub { $model });
  $self->helper(db => sub { $model->db });
  $self->config( $model->config );

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Protection from CSRF attack.
  $self->plugin('CSRFProtect');

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

  my @open_paths = (
    [qw(GET /)],
    [qw(GET /login)],
    [qw(POST /sessions)],
    [qw(GET  /signup)],
    [qw(POST /users)],
  );
  my $is_open = sub {
    my $c = shift;
    grep { $c->req->method eq $_->[0] and $c->req->url->path eq $_->[1] } @open_paths;
  };

  $r = $r->bridge('/')
    ->to(cb => sub {
           my $self = shift;
           $self->app->log->debug("[PATH] " . $self->req->url->path);
           $self->app->log->debug("[AUTH] " . $self->is_user_authenticated);
           $self->redirect_to('/login') and return 0
             unless($is_open->($self) or $self->is_user_authenticated);
           return 1;
         });

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # Sign Up
  $r->get('/signup')->to('signup#form');
  $r->post('/users')->to('users#create');

  # Login / Logout
  $r->get('/login')->to('login#form');
  $r->post('/sessions')->to('sessions#create');
  $r->get('/logout')->to('sessions#destroy');

  # Photos
  $r->get('/photos/new')->to('photos#new');
  $r->post('/photos')->to('photos#create');
  $r->get('/photos')->to('photos#index');
  $r->route('/photos/:id',
             id => qr/\d+/,
             format => [qw(png jpeg jpg gif)])
    ->via('GET')
    ->to('photos#show');

  # Events
  $r->get('/events/new')->to('events#new');
  $r->post('/events')->to('events#create');
}

1;
