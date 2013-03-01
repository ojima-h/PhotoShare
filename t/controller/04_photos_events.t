use Mojo::Base -strict;

use Test::More;
use Test::Deep;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

$t->prepare_user(
  name => 'user',
  email => 'user@example.com',
  password => 'secret',
);

$t->login_ok('user', 'secret');

my $event = $t->app->model->Event->create(
  name => 'Event 1',
  user => $t->current_user,
);

$t->get_ok('/photos/new')
  ->status_is(200);

my $default_event = $t->current_user->default_group->default_event;
my $custom_event = $t->current_user->events->find({name => 'Event 1'});
cmp_deeply($t->stash->{'events_info'},
           [
             [$default_event->name => $default_event->id],
             [$custom_event->name => $custom_event->id],
           ]);

change_ok(sub { $event->photos->count }, 2,
          sub {
            $t->post_ok('/photos',
                        form => {
                          'event-id'   => $event->id,
                          'photo-data' => [ {file => $ENV{MOJO_APP_ROOT} . "/../t/images/mojo.png"},
                                            {file => $ENV{MOJO_APP_ROOT} . "/../t/images/camel.png"} ],
                          csrftoken => $t->csrftoken
                        })
              ->redirect_ok('/photos');
          });

done_testing;




