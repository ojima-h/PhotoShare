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

__PACKAGE__->has_many(
  user_group_rs => 'PhotoShareModel::Schema::Result::UserGroup', 'user_id'
);
__PACKAGE__->many_to_many(
  groups => user_group_rs => '_group'
);

1;
