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

$t->get_ok('/events/new')
  ->status_is(200);

change_ok( sub { Event->count }, 1,
           sub {
             $t->post_ok('/events', form => {
               event_name => 'Event 1',
               csrftoken => $t->csrftoken,
             })->redirect_to(qr#http://localhost:\d+/events#);
           });

done_testing;
