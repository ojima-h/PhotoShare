use utf8;
package PhotoShareModel::Schema::Result::Photo;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('photos');
__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
  },
  content_type => {
    data_type => 'string',
  },
  event_id => {
    data_type => 'integer',
  },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  event => 'PhotoShareModel::Schema::Result::Event', 'event_id'
);

#
# Custom Methods
#
sub filename {
  my $self = shift;

  # content_type は image/*** となっているはず、と信じて
  # 先頭の image を除く
  $self->id . '.'  . substr($self->content_type, 6);
}

1;
