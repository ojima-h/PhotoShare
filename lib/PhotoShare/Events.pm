package PhotoShare::Events;
use Mojo::Base 'Mojolicious::Controller';

sub create {
  my $self = shift;
  my $event_name = $self->param('event_name');

  my $event = $self->model->Event->create(
    name => $event_name,
    user => $self->user,
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
