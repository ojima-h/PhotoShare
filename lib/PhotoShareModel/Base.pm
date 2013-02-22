package PhotoShareModel::Base;
use strict;
use warnings;

use Carp qw/carp croak/;

sub new {
  my $class = shift;
  my $app   = shift;

  bless {
    app => $app
  }, $class;
}

sub app   { shift->{app} }
sub config { shift->{app}->config }
sub db    {
  my $self = shift;
  if (my $table = shift) {
    $self->{app}->db->resultset($table);
  } else {
    $self->{app}->db;
  }
}

1;

