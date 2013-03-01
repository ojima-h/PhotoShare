package PhotoShare::Events;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  my $user = $self->current_user;

  my @events = $user->events->all;

  $self->render(events => \@events);
}

sub create {
  my $self = shift;
  my $event_name = $self->param('event-name');

  my $event = $self->model->Event->create(
    name => $event_name,
    user => $self->current_user,
  );

  if ($event) {
    $self->flash('alter-success' => "イベント $event_name が作成されました");
    $self->redirect_to('/events');
  } else {
    $self->flash('alter-error'   => "イベントを作成できませんでした");
    $self->redirect_to('/events/new');
  }
}

sub show {
  my $self = shift;
  my $id = $self->param('id');
  my $event = $self->app->model->db->resultset('Event')->find($id);

  $self->render(event => $event);
}

sub edit {
  my $self = shift;
  my $id = $self->param('id');
  my $event = $self->app->model->db->resultset('Event')->find($id);

  $event->name($self->param('event-name')) if $self->param('event-name');
  $event->passphrase($self->param('event-passphrase')) if defined $self->param('event-passphrase');

  if ($event->update) {
    $self->flash('alert-success' => 'イベント ' . $event->name . ' は変更されました');
  } else {
    $self->flash('alert-error' => 'イベント ' . $event->name . ' を変更できませんでした');
  }

  $self->redirect_to('/events/' . $event->id);
}



1;
