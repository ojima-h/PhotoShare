package PhotoShare::Photos;
use Mojo::Base 'Mojolicious::Controller';

use IO::Scalar;
use File::MMagic;

use PhotoShareModel::Photo;

sub create {
  my $self = shift;

  if ($self->is_user_authenticated) {
  #my @uploads = grep { $_->name eq 'photo-data' } @{ $self->req->uploads };
    my @uploads = $self->param('photo-data');

    my $mm = File::MMagic->new;
    for my $upload (@uploads) {
      my $data = $upload->slurp;

      my $mime_type;
      {
        open my $handle, '<', \$data;
        binmode $handle;
        $mime_type = $mm->checktype_filehandle($handle);
      }
      next unless grep { $mime_type eq $_ } qw(image/png image/jpeg image/jpg image/gif);

      $self->model->Photo->create(
        data         => $data,
        content_type => $mime_type,
        user      => $self->current_user,
      );
    }

    $self->redirect_to('/photos');
  } else {
    $self->redirect_to('/login');
  }
}

sub index {
  my $self = shift;

  my @photos = $self->current_user->photos->search(undef, {
    select => [qw/id content_type/]
  });

  # content_type は image/*** となっているはず、と信じて
  # 先頭の image を除く
  my @photo_names = map {$_->id . '.' . substr($_->content_type, 6)} @photos;

  $self->stash(photo_names => \@photo_names);

  $self->render;
}

sub show {
  my $self = shift;
  my $photo_id = $self->stash('id');
  my $format   = $self->stash('format');

  my $photo = $self->model->db->resultset('Photo')->find($photo_id);

  if ('image/' . $format eq $photo->content_type) {
    my $photos_dir = $self->model->config('photo_dir');
    my $photo_path = File::Spec->catfile($photos_dir, $photo_id . '.' . $format);

    my $fh = IO::File->new($photo_path, 'r');
    $fh->binmode;
    $fh->read(my $data, -s $photo_path);

    $self->render_data($data, format => $photo->content_type, status => 200);
  } else {
    $self->render_text('Invalid requset!', status => 403);
  }
}

1;
