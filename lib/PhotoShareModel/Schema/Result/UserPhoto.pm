use utf8;
package PhotoShareModel::Schema::Result::UserPhoto;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('users_photos');

__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT users_groups.user_id user_id, photos.id photo_id
        FROM
          ((users_groups
            JOIN groups ON users_groups.group_id = groups.id)
              JOIN events ON groups.id = events.group_id)
                JOIN photos ON events.id = photos.event_id"
);
# __PACKAGE__->result_source_instance->view_definition(
#   "SELECT users_groups.user_id user_id, photos.id photo_id
#         FROM users_groups, photos
#           WHERE users_groups.group_id = group.id
#             AND group.id = events.group_id
#             AND events.id = photo.event_id"
# );

__PACKAGE__->add_columns(
  user_id => {
    data_type => 'integer',
  },
  photo_id => {
    data_type => 'integer',
  },
);

__PACKAGE__->belongs_to(
  _user  => 'PhotoShareModel::Schema::Result::User'  => 'user_id'
);
__PACKAGE__->belongs_to(
  _photo => 'PhotoShareModel::Schema::Result::Photo' => 'photo_id'
);

1;
