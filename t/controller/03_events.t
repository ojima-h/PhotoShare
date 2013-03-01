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
             })->redirect_ok('/events');
           });
ok $t->current_user->events->find({name => 'Event 1'});

#
# Edit Events
#

my $event = $t->current_user->events->first;
my $event_id = $event->id;
$t->get_ok('/events/' . $event->id);

$t->post_ok('/events/' . $event->id . '/edit',
            form => {
              'event-passphrase' => 'PASSPHRASE',
              csrftoken => $t->csrftoken,
            })
  ->redirect_ok("/events/$event_id");

is Event->find($event->id)->passphrase, 'PASSPHRASE';

done_testing;
