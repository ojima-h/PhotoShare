package PhotoShareModel::Photo;
use strict;
use warnings;

use Carp qw/carp croak/;

use base 'PhotoShareModel::Base';

use File::Spec;

sub create {
  my $self = shift;
  my %args = @_;
  my ($user, $content_type, $data) = ($args{user}, $args{content_type}, $args{data});

  my $event_id = $args{event_id} // $user->default_group->default_event->id;

  my $photo = $self->db('Photo')->create({
    content_type => $content_type,
    event_id     => $event_id,
  });

  $content_type =~ qr#\Aimage/(png|jpg|jpeg|gif)\Z#;
  my $ext = $1;

  my $filename = File::Spec->catfile($self->app->config->{photo_dir},
                                     $photo->id . '.' . $ext);

  my $file = IO::File->new($filename, '>')
    or croak("Failed to open file $filename: $!");
  $file->binmode;
  $file->write($data);

  $photo;
}

1;
