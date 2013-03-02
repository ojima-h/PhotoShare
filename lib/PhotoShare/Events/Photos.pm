package PhotoShare::Events::Photos;
use Mojo::Base 'Mojolicious::Controller';

use PhotoShareModel::Photo;

sub index {
  my $self = shift;
  my $event_id = $self->param('id');
  my $event = $self->app->model->Event($event_id);

  $self->render("/events/photos/index", event => $event);
}

sub show {
  my $self = shift;
  my $event_id = $self->stash('id');
  my $event    = $self->app->model->Event($event_id);
  my $photo_id = $self->stash('photo_id');
  my $format   = $self->stash('format');
  my $photo    = $self->app->model->Photo($photo_id);

  $self->render_text('Invalid requset!', status => 403) and return
    unless $photo->format eq $format;

  my $data = $photo->slurp;

  $self->render_data($$data, format => $photo->content_type, status => 200);
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

  if ($self->authenticate_event($event, $passphrase)) {
    $self->redirect_to("/events/$event_id/photos");
  } else {
    $self->flash('alert-error' => "あいことばが間違っています");
    $self->redirect_to("/events/$event_id/photos/checkin");
  }
}

1;
