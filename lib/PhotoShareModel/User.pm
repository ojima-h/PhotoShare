package PhotoShareModel::User;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

sub create {
  my $self = shift;
  my %param = @_;

  my $user = $self->db('User')->new({
    name     => $param{name},
    email    => $param{email},
    password => $param{password},
  });
  my $default_group = $self->app->Group->create(
    name => "default: " . $param{name},
  );

  $user->default_group($default_group);
  $user->insert;
}

1;
