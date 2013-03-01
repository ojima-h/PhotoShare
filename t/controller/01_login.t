use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

$t->prepare_user(
  name     => 'bob',
  password => 'secret',
  email    => 'test\@examle.com',
);

$t->ua->max_redirects(0);

$t->get_ok('/login')
  ->status_is(200)
  ->element_exists('form[action=/sessions]')
  ->element_exists('form input#name')
  ->element_exists('form input#password');

$t->post_ok('/sessions', form => {
  name => 'bob',
  password => 'secret',
  csrftoken => $t->csrftoken,
})->redirect_to(qr#http://localhost:\d+/$#);

$t->get_ok('/login');
$t->post_ok('/sessions', form => {
  name => 'bob',
  password => 'wrong',
  csrftoken => $t->csrftoken,
})->redirect_to(qr#http://localhost:\d+/login/?$#);

# $t->delete_ok('/sessions')
#   ->status_is(200)
#   ->text_is('#message' => 'logout');
$t->ua->max_redirects(1);
$t->get_ok('/logout')
  ->status_is(200)
  ->text_is('#message' => 'ログアウトしました')
  ->text_isnt('ul.nav li:last-child a' => 'Logout');    # 実際にログアウトしたことを確認

done_testing;








