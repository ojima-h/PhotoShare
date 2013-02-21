use utf8;
package PhotoShareModel::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('users');
__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
  },
  name => {
    data_type => 'text',
  },
  email => {
    data_type => 'text',
  },
  password => {
    data_type =>  'text',
  },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(
  ['name'],
  ['email'],
);

1;
