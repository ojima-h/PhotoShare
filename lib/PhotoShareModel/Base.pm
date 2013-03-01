package PhotoShareModel::Base;
use strict;
use warnings;

use Carp qw/carp croak/;

sub new {
  my ($class, $app, $id) = @_;

  my $self = bless {
    app => $app
  }, $class;

  if (defined $id) {
    my $table = $class->_table_name;
    $self->{result} = $self->db($table)->find($id)
      or croak "Data not found in $table";
  }

  $self;
}

# Delegating Methods
sub update       { shift->_result->update(@_) }

sub _result { shift->{result} }

sub app   { shift->{app} }
sub config { shift->{app}->config }
sub db    {
  my $self = shift;
  my $table = shift;
  $self->{app}->db->resultset($table);
}

1;

