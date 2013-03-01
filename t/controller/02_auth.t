use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

#
# Prepare
#
$t->prepare_user(
  name => 'user',
  email => 'user@example.com',
  password => 'secret',
);

$t->login_ok('user', 'secret');

$t->upload_photos("mojo.png", "camel.png");

$t->logout_ok;


#
# Test
#
$t->get_ok('/photos')
  ->redirect_ok('/login');

$t->login_ok('user', 'secret');

$t->get_ok('/photos')
  ->status_is(200);

done_testing;
