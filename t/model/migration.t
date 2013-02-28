use Test::More;

use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => ['dbi:SQLite:dbname=:memory:','',''],
}, qw/ User Group UserGroup /;

fixtures_ok[
  User => [
    [qw/ id name email password /],
    [1, qw/ userA A\@examlpe.com secret /],
    [2, qw/ userB B\@examlpe.com secret /],
  ],
  Group => [
    [qw/ id name /],
    [1, qw/ groupA /],
    [2, qw/ groupB /],
  ],
];

ok my $user = User->first;
ok my $groupA = Group->find(1);
ok my $groupB = Group->find(2);

can_ok $user, 'groups';
ok $user->add_to_groups($groupA);
ok $user->add_to_groups($groupB);

ok my @groups = $user->groups;
is UserGroup->count, 2;

done_testing;
