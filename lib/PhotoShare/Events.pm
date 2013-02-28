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

1;
