use utf8;
package Schema::Result::DbixMigration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::DbixMigration

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dbix_migration>

=cut

__PACKAGE__->table("dbix_migration");

=head1 ACCESSORS

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 64

=head2 value

  data_type: 'char'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "char", is_nullable => 0, size => 64 },
  "value",
  { data_type => "char", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-11 19:29:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y/NY+BA+PGtPa2KvCDj4dw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
