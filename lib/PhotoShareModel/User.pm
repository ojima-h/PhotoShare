package PhotoShareModel::User;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

sub create {
  my $self = shift;
  my ($name, $email, $password) = @_;

  my $user = $self->User->create({
      name => $name,
      email => $email,
      password => $password,
    });
}

1;
