package PhotoShareModel::Group;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

sub create {
  my $self = shift;
  my %param = @_;

  my $group = $self->db('Group')->create({
    name => $param{name},
  });
  my $default_event = $self->db('Event')->create({
    name => "default: " . $param{name},
    group_id => $group->id,
  });

  $group->default_event($default_event);
  $group->update;
}

1;
