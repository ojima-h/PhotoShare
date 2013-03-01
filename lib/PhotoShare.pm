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
      return $app->model->User($uid);
    },
    'validate_user' => sub {
      my ($app, $name, $password, $extradata) = @_;

      $app->model->User->validate(
        name     => $name,
        password => $password
      );
    },
  });

  # Router
  my $r = $self->routes;

  {
    my $app = $self;

    $r = $r->bridge('/')
      ->to(cb => sub {
             my $self = shift;
             $self->redirect_to('/login') and return 0
               if ($app->_is_restricted($self->req) and not $self->is_user_authenticated);
             return 1;
           });
  }

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
  $r->get('/photos/new')->to('photos#build');
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
  $r->get('/events')->to('events#index');
  $r->route('/events/:id', id => qr/\d+/)
    ->via('GET')
    ->to('events#show');
  $r->route('/events/:id/edit', id => qr/\d+/)
    ->via('POST')
    ->to('events#edit');

  # Events/Photos
  $r->route('/events/:id/photos', id => qr/\d+/)
    ->via('GET')
    ->to('events-photos#index');
  $r->route('/events/:id/photos/checkin', id => qr/\d+/)
    ->via('GET')
    ->to('events-photos#checkin');
  $r->route('/events/:id/photos/sessions', id => qr/\d+/)
    ->via('POST')
    ->to('events-photos#create_session');
  $r->route('/events/:id/photos/:photo_id',
            id => qr/\d+/,
            photo_id => qr/\d+/,
            format => [qw/png jpeg jpg gif/])
    ->via('GET')
    ->to('events-photos#show');
}

sub _is_restricted {
  my $self = shift;
  my $req = shift;

  my @open_paths = (
    ['GET'  => qr#\A/\Z#],
    ['GET'  => qr#\A/login\Z#],
    ['POST' => qr#\A/sessions\Z#],
    ['GET'  => qr#\A/signup\Z#],
    ['POST' => qr#\A/users\Z#],
    ['GET'  => qr#\A/events/\d+/photos#],
    ['POST' => qr#\A/events/\d+/photos#],
  );

  not ( grep { $req->method eq $_->[0] and $req->url->path =~ $_->[1] } @open_paths );
}

1;
