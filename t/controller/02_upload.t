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

$t->get_ok('/photos/new')
  ->status_is(200)
  ->element_exists('form[action=/photos]')
  ->element_exists('form input#photo-data');

change_ok(sub { Photo->count }, 2,
          sub {
            $t->post_ok('/photos',
                        form => {
                          'photo-data' => [ {file => $ENV{MOJO_APP_ROOT} . "/../t/images/mojo.png"},
                                            {file => $ENV{MOJO_APP_ROOT} . "/../t/images/camel.png"} ],
                          csrftoken => $t->csrftoken
                        })
              ->status_is(302)
              ->header_like(Location => qr#http://localhost:\d+/photos$#);
          });

done_testing;




