package PhotoShareModel;
use strict;
use warnings;

use Carp qw/ carp croak /;

BEGIN {
  use FindBin;
  our $ROOT = $FindBin::Bin;
}

use File::Spec;

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ mode /);

use PhotoShareModel::User;
use PhotoShareModel::Group;

use PhotoShareModel::Config;

sub new {
  my $class = shift;
  my $mode = shift;

  my $config = PhotoShareModel::Config->load($mode);
  $config->{root} = our $ROOT;
  $config->{photo_dir} = File::Spec->catfile($ROOT, '..', 'share' ,  'photos', $mode);

  bless {
    mode => $mode,
    config => $config,
  }, $class;
}

sub config {
  my $self = shift;

  if (@_ == 0) {
    $self->{config};
  } elsif (@_ == 1) {
    $self->{config}->{$_[0]};
  } elsif (@_) {
    map { $self->{config}->{$_} } @_;
  }
}

sub db {
  my $self = shift;
  my ($dsn, $user, $password) = @{ $self->config->{db} };
  PhotoShareModel::Schema->connect(
    $dsn,
    $user,
    $password,
    { AutoCommit => 1 },
  );
}

sub User { PhotoShareModel::User->new(shift) }
sub Group { PhotoShareModel::Group->new(shift) }
sub Photo { PhotoShareModel::Photo->new(shift) }

1;
