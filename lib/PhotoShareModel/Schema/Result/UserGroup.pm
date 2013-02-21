use utf8;
package PhotoShareModel::Schema::Result::UserGroup;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('users_groups');
__PACKAGE__->add_columns(
  user_id => {
    data_type => 'integer',
  },
  group_id => {
    data_type => 'integer',
  },
);

__PACKAGE__->set_primary_key('user_id', 'group_id');
__PACKAGE__->belongs_to(
  '_user' => 'PhotoShareModel::Schema::Result::User', 'user_id'
);
__PACKAGE__->belongs_to(
  '_group' => 'PhotoShareModel::Schema::Result::Group', 'group_id'
);

1;
