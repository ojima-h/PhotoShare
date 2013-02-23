package PhotoShareModel::User;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

sub create {
  my $self = shift;
  my %param = @_;

  my $user = $self->db('User')->create({
    name     => $param{name},
    email    => $param{email},
    password => $param{password},
  });
  my $default_group = $self->app->Group->create(
    name => "default: " . $param{name},
  );

  $user->add_to_groups($default_group);
  $user->default_group($default_group);
  $user->update;
}

1;
