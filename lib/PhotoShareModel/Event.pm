package PhotoShareModel::Event;
use strict;
use warnings;

use Carp qw/carp croak/;

use base 'PhotoShareModel::Base';

=head1 NAME

PhotoShareModel::Event

=head1 SYNOPSIS

L<PhotoShareModel::Photo> 参照

=cut

=head1 METHODS

=head2 new($app, $photo_id)
$app      -- L<PhotoShareModel> instance.
$photo_id -- photo id in the database. (optional)

=cut

sub _table_name { 'Event' }

# Delegating Methods
sub id         { shift->_result->id(@_) }
sub name       { shift->_result->name(@_) }
sub passphrase { shift->_result->passphrase(@_) }
sub group      { shift->_result->group(@_) }
sub photos     { shift->_result->photos(@_) }

sub create {
  my $self = shift;
  my %param = @_;

  my $group = $param{user}->default_group;

  $self->db('Event')->create({
    name => $param{name},
    group_id => $group->id,
  });
}

sub validate {
  my ($self, $passphrase) = @_;

  if ($self->passphrase eq $passphrase) {
    $self->passphrase;
  } else {
    undef
  }
}
sub is_valid_key {
  my ($self, $key) = @_;

  $key eq $self->passphrase;
}

1;
