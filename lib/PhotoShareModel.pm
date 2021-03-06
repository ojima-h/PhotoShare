package PhotoShareModel;
use strict;
use warnings;

use Carp qw/ carp croak /;

use File::Spec;

use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ mode /);

use PhotoShareModel::User;
use PhotoShareModel::Group;
use PhotoShareModel::Event;
use PhotoShareModel::Photo;

use PhotoShareModel::Config;

sub new {
  my $class = shift;
  my $mode = shift;

  my $config = PhotoShareModel::Config->load($mode);
  $config->{root} = $ENV{MOJO_APP_ROOT};
  $config->{photo_dir} = File::Spec->catfile($ENV{MOJO_APP_ROOT}, '..', 'share', 'photos', $mode);

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
  my ($dsn, $user, $password, $extra_args) = @{ $self->config->{db} };
  $extra_args->{AutoCommit} = 1;

  PhotoShareModel::Schema->connect(
    $dsn,
    $user,
    $password,
    $extra_args,
  );
}

sub User  { my $self = shift; PhotoShareModel::User->new($self, @_) }
sub Group { my $self = shift; PhotoShareModel::Group->new($self, @_) }
sub Event { my $self = shift; PhotoShareModel::Event->new($self, @_) }
sub Photo { my $self = shift; PhotoShareModel::Photo->new($self, @_) }

1;
