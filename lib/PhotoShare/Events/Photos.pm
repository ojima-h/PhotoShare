package PhotoShare::Events::Photos;
use Mojo::Base 'Mojolicious::Controller';

use PhotoShareModel::Photo;

sub index {
  my $self = shift;
  my $event_id = $self->param('id');
  my $event = $self->app->model->Event($event_id);

  if ($self->_is_authorized($event)) {
    $self->render("/events/photos/index", event => $event);
  } else {
    $self->redirect_to("/events/$event_id/photos/checkin");
  }
}
sub _is_authorized {
  my ($self, $event) = @_;

  $self->session('Event-Auth') and
    $self->session('Event-Auth')->{$event->id} eq $event->passphrase
}

sub show {
  my $self = shift;
  my $event_id = $self->stash('id');
  my $event = $self->app->model->Event($event_id);

  $self->render_text('Invalid requset!', status => 403) and return
    unless $self->_is_authorized($event);

  my $photo_id = $self->stash('photo_id');
  my $format   = $self->stash('format');
  my $photo    = $self->app->model->Photo($photo_id);

  $self->render_text('Invalid requset!', status => 403) and return
    unless $self->_is_type_correspond($photo, $format);

  my $data = $photo->slurp;

  $self->render_data($$data, format => $photo->content_type, status => 200);
}
sub _is_type_correspond {
  my ($self, $photo, $format) = @_;
  'image/' . $format eq $photo->content_type
}

sub checkin {
  my $self = shift;
  my $event_id = $self->param('id');
  my $event = $self->app->model->Event($event_id);

  $self->render('/events/photos/checkin', event => $event);
}

sub create_session {
  my $self = shift;
  my $event_id = $self->param('id');
  my $event = $self->app->model->Event($event_id);

  my $passphrase = $self->param('passphrase');

  if ($self->_authenticate_event($event, $passphrase)) {
    $self->flash('alert-success' => "あいことば -- OK");
    $self->redirect_to("/events/$event_id/photos");
  } else {
    $self->flash('alert-error' => "あいことばが間違っています");
    $self->redirect_to("/events/$event_id/photos/checkin");
  }
}
sub _authenticate_event {
  my ($self, $event, $passphrase) = @_;

  $self->session('Event-Auth' => {}) unless defined $self->session('Event-Auth');

  if ($event->passphrase eq $passphrase) {
    $self->session('Event-Auth')->{$event->id} = $passphrase;
    1;
  } else {
    0;
  }
}

1;
