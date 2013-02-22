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
      next unless grep { $mime_type eq $_ } qw(image/png image/jpeg image/gif);

      $self->model->Photo->create(
        data         => $data,
        content_type => $mime_type,
        user      => $self->current_user,
      );
    }

    $self->render('photos/new');
  } else {
    $self->redirect_to('/login');
  }
}

1;
