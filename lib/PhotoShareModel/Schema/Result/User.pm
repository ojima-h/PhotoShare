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
  default_group_id => {
    data_type => 'integer',
    is_nullable => 1,
  },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(
  ['name'],
  ['email'],
);

__PACKAGE__->has_many(
  _user_group_rs => 'PhotoShareModel::Schema::Result::UserGroup', 'user_id'
);
__PACKAGE__->many_to_many(
  groups => _user_group_rs => '_group'
);

__PACKAGE__->belongs_to(
  default_group => 'PhotoShareModel::Schema::Result::Group' => 'default_group_id'
);

__PACKAGE__->has_many(
  _user_photo_rs => 'PhotoShareModel::Schema::Result::UserPhoto', 'user_id'
);
__PACKAGE__->many_to_many(
  photos => _user_photo_rs => '_photo'
);

__PACKAGE__->has_many(
  _user_event_rs => 'PhotoShareModel::Schema::Result::UserEvent', 'user_id'
);
__PACKAGE__->many_to_many(
  events => _user_event_rs => '_event'
);

1;
