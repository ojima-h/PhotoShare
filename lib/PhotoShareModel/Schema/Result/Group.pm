use utf8;
package PhotoShareModel::Schema::Result::Group;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('groups');
__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
  },
  name => {
    data_type => 'text',
  },
  default_event_id => {
    data_type => 'integer',
    is_nullable => 1,
  }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(
  ['name'],
);
__PACKAGE__->has_many(
  'events' => 'PhotoShareModel::Schema::Result::Event', 'group_id'
);

__PACKAGE__->has_many(
  user_group_rs => 'PhotoShareModel::Schema::Result::UserGroup', 'group_id'
);
__PACKAGE__->many_to_many(
  users => user_group_rs => '_user'
);

__PACKAGE__->might_have(
  defalt_user => 'PhotoShareModel::Schema::Result::User' => 'default_group_id'
);

__PACKAGE__->belongs_to(
  default_event => 'PhotoShareModel::Schema::Result::Event' => 'default_event_id'
);
1;
