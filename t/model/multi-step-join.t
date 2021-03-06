use Test::More;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$ENV{MOJO_APP_ROOT}/../config.yml")->[0]{test}{db},
}, qw/ User Group Event Photo /;

use PhotoShareModel;

my $model = PhotoShareModel->new('test');
my $user = $model->User->create(
  name     => 'user_name',
  email    => 'email',
  password => 'secret'
);

my $user =  User->first;
my $event = $user->default_group->default_event;

ok (my $photo = Photo->create({
  content_type => 'image/png',
  event_id     => $event->id,
}));

can_ok $user, 'photos';
ok $user->photos->find($photo->id);

ok (my $event = Event->create({
  name => 'Event Name',
  group_id => $user->default_group->id,
}));
can_ok $user, 'events';
ok $user->events->find({name => 'Event Name'});

done_testing;
