use utf8;
package PhotoShareModel::Schema::Result::Event;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('events');
__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
  },
  name => {
    data_type => 'text',
  },
  group_id => {
    data_type => 'integer',
  },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(
  ['name'],
);

__PACKAGE__->belongs_to(
  group => 'PhotoShareModel::Schema::Result::Group', 'group_id'
);

__PACKAGE__->has_many(
  photos => 'PhotoShareModel::Schema::Result::Photo', 'event_id'
);

1;
