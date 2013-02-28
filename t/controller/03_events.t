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


#
# Create Event
#

$t->get_ok('/events/new')
  ->status_is(200);

change_ok( sub { Event->count }, 1,
           sub {
             $t->post_ok('/events', form => {
               'event-name' => 'Event 1',
               csrftoken => $t->csrftoken,
             })->redirect_to(qr#http://localhost:\d+/events#);
           });
ok $t->current_user->events->find({name => 'Event 1'});

done_testing;
