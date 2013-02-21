package PhotoShareModel::Base;
use strict;
use warnings;

sub new {
  my $class = shift;
  my $app   = shift;

  bless {
    app => $app
  }, $class;
}

sub config { shift->{app}->config }
sub db    { shift->{app}->db }
sub User  { shift->{app}->db->resultset('User'); }
sub Group { shift->{app}->db->resultset('Group'); }
sub Event { shift->{app}->db->resultset('Event'); }

1;

