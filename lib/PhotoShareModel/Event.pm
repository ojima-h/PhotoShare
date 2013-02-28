package PhotoShareModel::Event;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

sub create {
  my $self = shift;
  my %param = @_;

  my $group = $param{user}->default_group;

  $self->db('Event')->create({
    name => $param{name},
    group_id => $group->id,
  });
}

1;
