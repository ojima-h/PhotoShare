package PhotoShare::Photos;
use Mojo::Base 'Mojolicious::Controller';

use IO::Scalar;
use File::MMagic;

use PhotoShareModel::Photo;

sub index {
  my $self = shift;

  my @photos = $self->current_user->photos->search(undef, {
    select => [qw/id content_type/]
  });

  my $events_rs = $self->current_user->events;

  $self->stash(events_rs => $events_rs);

  $self->render;
}

sub build {
  my $self = shift;
  my $user = $self->current_user;

  $self->stash(events_info => $self->_events_info);
  $self->render('photos/new');
}

sub _events_info {
  my @events_info = map { [ $_->name => $_->id ] } shift->current_user->events->all;
  \@events_info;
}

sub create {
  my $self = shift;
  my @uploads = $self->param('photo-data');

  my $mm = File::MMagic->new;

  for my $upload (@uploads) {
    my $data      = $upload->slurp;
    my $mime_type = $self->_mime_type(\$data, $mm);
    my $event_id  = $self->param('event-id');
    my $user      = $self->current_user;

    next unless $self->_is_valid_mime_type($mime_type);

    $self->model->Photo->create(
      data         => $data,
      content_type => $mime_type,
      event_id     => $event_id,
      user         => $user,
    );
  }

  $self->redirect_to('/photos');
}

sub _mime_type {
  my ($self, $data_ref, $mmagic) = @_;

  open my $handle, '<', $data_ref;
  binmode $handle;
  return $mmagic->checktype_filehandle($handle);
}
sub _is_valid_mime_type {
  my ($self, $mime_type) = @_;

  grep { $mime_type eq $_ } qw(image/png image/jpeg image/jpg image/gif);
}

sub show {
  my $self = shift;
  my $id = $self->stash('id');
  my $format   = $self->stash('format');

  my $photo = $self->model->Photo($id);

  if ($format eq $photo->format) {
    my $data = $photo->slurp;

    $self->render_data($$data, format => $photo->content_type, status => 200);
  } else {
    $self->render_text('Invalid requset!', status => 403);
  }
}

1;
