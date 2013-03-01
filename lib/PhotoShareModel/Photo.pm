package PhotoShareModel::Photo;
use strict;
use warnings;

use Carp qw/carp croak/;

use base 'PhotoShareModel::Base';

use File::Spec;

=head1 NAME

PhotoShareModel::Photo

=head1 SYNOPSIS

  use PhotoShareModel::Photo;

  my $app = PhotoShareModel->new('development');

  my $photo = PhotoShareModel::Photo->new($app);

  # create the photo entry in database
  $photo->create(
    user         => $user,
    content_type => 'image/png',
    data         => $data
  );

  my $photo_with_result = PhotoShareModel::Photo->new($photo_id);

  # Delegate to DBIx::Class::Schema::Result class
  $photo_with_result->id;
  $photo_with_result->content_type;

  # ファイルシステム内でのパス
  my $path = $photo->path;

  # Load photo data.
  my $data_ref = $photo_with_result->slurp;
  print $$data_ref;

=cut

=head1 METHODS

=head2 new($app, $photo_id)
$app      -- L<PhotoShareModel> instance.
$photo_id -- photo id in the database. (optional)

=cut

sub _table_name { 'Photo' }

# Delegating Methods
sub id           { shift->_result->id(@_) }
sub content_type { shift->_result->content_type(@_) }
sub event        { shift->_result->event(@_) }
sub name         { shift->_result->name(@_) }
sub format       { shift->_result->format(@_) }

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

sub path {
  my $self = shift;

  croak '#path is not a class method' unless ref $self;

  File::Spec->catfile(
    $self->app->config('photo_dir'),
    $self->_result->name,
  );
}

sub slurp {
  my $self = shift;

  croak '#slurp is not a class method' unless ref $self;

  my $path = $self->path;

  my $fh = IO::File->new($path, 'r');
  $fh->binmode;
  $fh->read(my $data, -s $path);

  return \$data;
}

1;
