use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

my $t = Test::PhotoShare->new('PhotoShare');

$t->get_ok('/signup')
  ->status_is(200)
  ->element_exists('form#signup_form input[name=name]')
  ->element_exists('form#signup_form input[name=password]')
  ->element_exists('form#signup_form input[name=password-confirm]')
  ->element_exists('form#signup_form input[name=email]');

$t->post_ok('/users', form => { name => 'bob',
                                password => 'pass',
                                'password-confirm' => 'pass',
                                email => 'test@example.com',
                                csrftoken => $t->csrftoken,
                               })
  ->redirect_to(qr#http://localhost:\d+/login/?$#);

$t->get_ok('/login');
$t->post_ok('/sessions', form => {
  name      => 'bob',
  password  => 'pass',
  csrftoken => $t->csrftoken,
});

ok $t->current_user;
ok $t->current_user->default_group;
ok $t->current_user->default_group->default_event;;

done_testing;

