use Mojo::Base -strict;

use Test::More;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$ENV{MOJO_APP_ROOT}/../config.yml")->[0]{test}{db},
}, qw/ User Group Event /;

BEGIN {
  use_ok 'PhotoShareModel';
}

my %counts = (
  User  => User->count,
  Group => Group->count,
  Event => Event->count,
);

my $model = PhotoShareModel->new('test');
my $user = $model->User->create(
  name     => 'user_name',
  email    => 'email',
  password => 'secret'
);

is User->count,  $counts{User} + 1;
is Group->count, $counts{Group} + 1;
is Event->count, $counts{Event} + 1;

ok $user->default_group;
ok $user->default_group->default_event;

done_testing;
