use utf8;
package Schema::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Group

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<groups>

=cut

__PACKAGE__->table("groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
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
  "name",
  { data_type => "text", is_nullable => 0 },
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

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head1 RELATIONS

=head2 events

Type: has_many

Related object: L<Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "Schema::Result::Event",
  { "foreign.group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_groups

Type: has_many

Related object: L<Schema::Result::UsersGroup>

=cut

__PACKAGE__->has_many(
  "users_groups",
  "Schema::Result::UsersGroup",
  { "foreign.group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-21 09:04:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:arrLDC8wrLjkVT2wvHrJrQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->many_to_many(users => 'users_groups', 'users');

1;
