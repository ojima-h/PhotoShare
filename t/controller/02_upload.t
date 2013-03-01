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

$t->get_ok('/photos/new')
  ->status_is(200)
  ->element_exists('form[action=/photos]')
  ->element_exists('form input#photo-data');

my $default_event = $t->current_user->default_group->default_event;
change_ok(sub { $default_event->photos->count }, 2,
          sub {
            $t->post_ok('/photos',
                        form => {
                          'photo-data' => [ {file => $ENV{MOJO_APP_ROOT} . "/../t/images/mojo.png"},
                                            {file => $ENV{MOJO_APP_ROOT} . "/../t/images/camel.png"} ],
                          csrftoken => $t->csrftoken
                        })
              ->redirect_ok('/photos');
          });

done_testing;




