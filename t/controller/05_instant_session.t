use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

$t->prepare_user(
  name => 'user',
  email => 'user@example.com',
  password => 'secret',
);

$t->login_ok('user', 'secret');

my $event = $t->current_user->default_group->default_event;

$t->upload_photos(qw(camel.png mojo.png));

my $photo = $event->photos->first;

$t->set_passphrase($event, 'PASSPHRASE');

$t->logout_ok;

my $id = $event->id;
$t->get_ok("/events/$id/photos")
  ->redirect_to(qr#http://localhost:\d+/events/$id/photos/checkin/?$#);
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->status_is(403);
$t->get_ok("/events/$id/photos/checkin")
  ->status_is(200);
$t->post_ok("/events/$id/photos/sessions", form => {
  passphrase => 'PASSPHRASE',
  csrftoken  => $t->csrftoken,
})->redirect_to(qr#http://localhost:\d+/events/$id/photos?$#);
$t->get_ok("/events/$id/photos")
  ->status_is(200)
  ->element_exists('img');
$t->get_ok("/events/$id/photos/" . $photo->name)
  ->status_is(200);

done_testing;
