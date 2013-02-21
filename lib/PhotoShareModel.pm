package PhotoShareModel;
use strict;
use warnings;

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ mode /);

use PhotoShareModel::User;
use PhotoShareModel::Group;

use PhotoShareModel::Config;

sub new {
  my $class = shift;
  my $mode = shift;

  bless {
    mode => $mode,
    config => PhotoShareModel::Config->load($mode),
  };
}

sub config { shift->{config} }

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


1;
