use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

$t->prepare_user(
  name => 'user_1',
  email => 'user_1@example.com',
  password => 'secret',
);
$t->prepare_user(
  name => 'user_2',
  email => 'user_2@example.com',
  password => 'secret',
);

$t->login_ok('user_1', 'secret');

my $event = $t->current_user->default_group->default_event;

$t->upload_photos(qw(camel.png mojo.png));

my $photo = $event->photos->first;

$t->set_passphrase($event, 'PASSPHRASE');

$t->reset_session;

#
# Un-authenticated user
#
my $id = $event->id;
$t->get_ok("/events/$id/photos")
  ->redirect_ok("/events/$id/photos/checkin");
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->redirect_ok("/events/$id/photos/checkin");
$t->get_ok("/events/$id/photos/checkin")
  ->status_is(200);
$t->post_ok("/events/$id/photos/sessions", form => {
  passphrase => 'PASSPHRASE',
  csrftoken  => $t->csrftoken,
})->redirect_ok("/events/$id/photos");
$t->get_ok("/events/$id/photos")
  ->status_is(200)
  ->element_exists('img');
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->status_is(200);

$t->reset_session;

#
# authenticated, but not an owner
#
$t->login_ok('user_2', 'secret');

$t->get_ok("/events/$id/photos")
  ->redirect_ok("/events/$id/photos/checkin");
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->redirect_ok("/events/$id/photos/checkin");

$t->reset_session;

#
# owner
#
$t->login_ok('user_1', 'secret');

$t->get_ok("/events/$id/photos")
  ->status_is(200);
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->status_is(200);

done_testing;
