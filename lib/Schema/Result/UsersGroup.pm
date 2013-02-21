use utf8;
package Schema::Result::UsersGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::UsersGroup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users_groups>

=cut

__PACKAGE__->table("users_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'text'
  is_nullable: 1

=head2 updated_at

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  { data_type => "text", is_nullable => 1 },
  "updated_at",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<Schema::Result::Group>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Schema::Result::Group",
  { id => "group_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-21 09:04:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9mSnDQp7awiwa/vU7qnRTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
