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
# Upload
#
$t->post_ok('/photos',
            form => {'photo-data' => [ {file => $ENV{MOJO_APP_ROOT} . "/../t/images/mojo.png"},
                                       {file => $ENV{MOJO_APP_ROOT} . "/../t/images/camel.png"} ],
                     csrftoken => $t->csrftoken});

#
# Show
#
$t->get_ok('/photos')
  ->status_is(200)
  ->element_exists('img');
my $photo = $t->tx->res->dom->at('img')->attrs('src');
$t->get_ok($photo)
  ->status_is(200)
  ->header_is('MIME-type: image/png');
$t->get_ok('/photos/1.gif')
  ->status_is(403);

done_testing;
