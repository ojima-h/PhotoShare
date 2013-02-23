use Test::More;

use FindBin;
use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$FindBin::Bin/../../config.yml")->[0]{test}{db},
}, qw/ User Group Event Photo UserGroup/;

use PhotoShareModel;

my $model = PhotoShareModel->new('test');

my $user = $model->User->create(
  name     => 'user_name',
  email    => 'email',
  password => 'secret'
);

ok my $user =  User->first;
ok my $group = $user->default_group;
ok my $event = $user->default_group->default_event;

ok $user->groups->find($group->id);

done_testing;
