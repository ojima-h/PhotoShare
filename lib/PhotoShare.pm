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
  $self->plugin('PhotoShare::Plugin::CSRFProtect');

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

  # Event Authentication
  $self->plugin('PhotoShare::Plugin::EventAuthentication');

  # Router
  my $r = $self->routes;

  # Root
  $r->get('/')->to('example#welcome');

  ## un-authenticated users only
  {
    my $app = $self;
    my $r_unauthorized = $r->bridge('/')
      ->to(cb => sub {
             my $self = shift;

             $self->redirect_to('/') and return 0
               if $self->is_user_authenticated;

             return 1;
           });

    # Sign Up
    $r_unauthorized->get ('/signup')->to('signup#form');
    $r_unauthorized->post('/signup')->to('signup#confirm');
    $r_unauthorized->get ('/signup/confirm-email')->to('signup#confirm_email');
    $r_unauthorized->get ('/users/create')->to('users#create');

    # Login
    $r_unauthorized->get('/login')->to('login#form');
    $r_unauthorized->post('/sessions')->to('sessions#create');
  }

  ## authenticated users only
  {
    my $app = $self;
    my $r_restricted = $r->bridge('/')
      ->to(cb => sub {
             my $self = shift;

             $self->redirect_to('/login') and return 0
               unless $self->is_user_authenticated;

             return 1;
           });

    # Logout
    $r->get('/logout')->to('sessions#destroy');

    # Photos
    $r_restricted->get ('/photos/new')->to('photos#build');
    $r_restricted->post('/photos')    ->to('photos#create');
    $r_restricted->get ('/photos')    ->to('photos#index');
    $r_restricted->route('/photos/:id',
                         id => qr/\d+/,
                         format => [qw(png jpeg jpg gif)])
                 ->via('GET')
                 ->to('photos#show');

    # Events
    $r_restricted->get('/events/new')->to('events#new');
    $r_restricted->post('/events')->to('events#create');
    $r_restricted->get('/events')->to('events#index');
    $r_restricted->route('/events/:id', id => qr/\d+/)
                 ->via('GET')
                 ->to('events#show');
    $r_restricted->route('/events/:id/edit', id => qr/\d+/)
                 ->via('POST')
                 ->to('events#edit');

  }

  # Events/Photos
  {
    my $r_event = $r->route('/events/:id/photos', id => qr/\d+/);

    $r_event->get ('/checkin') ->to('events-photos#checkin');
    $r_event->post('/sessions')->to('events-photos#create_session');

    ## restricted routes
    {
      #my $r_event_restricted = $r_event;
      my $r_event_restricted = $r_event->bridge('')->to(
        cb => sub {
          my $self  = shift;
          my $id    = $self->stash('id');
          my $event = $self->model->Event($id);

          $self->redirect_to("/events/$id/photos/checkin") and return
            unless $self->is_event_authorized($event);

          $self->stash(event => $event);
          return 1;
        }
      );

      $r_event_restricted->get('')->to('events-photos#index');
      $r_event_restricted->route('/:photo_id', photo_id => qr/\d+/, format => [qw/png jpeg jpg gif/])
                         ->via('GET')
                         ->to('events-photos#show');
    }
  }
}

1;
