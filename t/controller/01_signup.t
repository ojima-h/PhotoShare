use Mojo::Base -strict;

use Test::More;
use Test::PhotoShare;

use Email::Sender::Simple;

my $t = Test::PhotoShare->new('PhotoShare');

$t->get_ok('/signup')
  ->status_is(200)
  ->element_exists('form#signup_form[action=/signup]')
  ->element_exists('form#signup_form input[name=name]')
  ->element_exists('form#signup_form input[name=password]')
  ->element_exists('form#signup_form input[name=password-confirm]')
  ->element_exists('form#signup_form input[name=email]');

$t->post_ok('/signup', form => { name => 'bob',
                                 password => 'pass',
                                 'password-confirm' => 'pass',
                                 email => 'test@example.com',
                                 csrftoken => $t->csrftoken,
                               })
  ->redirect_ok('/signup/confirm-email');

$t->get_ok('/signup/confirm-email')
  ->status_is(200);

my @deliveries = Email::Sender::Simple->default_transport->deliveries;
my $delivery = shift @deliveries;

ok $delivery, 'mail is delivered';
is $delivery->{email}->get_header('To'), 'test@example.com', 'mail is delivered to test@examlpe.com';
like $delivery->{email}->get_body, qr{https?://localhost:\d+(/users/create\?token=\S+)};

my ($url) = ($delivery->{email}->get_body =~ qr{https?://localhost:\d+(/users/create\?token=\S+)});

$t->get_ok($url)
  ->redirect_ok('/');

ok $t->current_user;
ok $t->current_user->default_group;
ok $t->current_user->default_group->default_event;;
is $t->current_user->name, 'bob', 'user created and logged in';

$t->reset_session;

$t->get_ok('/login');
$t->post_ok('/sessions', form => {
  name      => 'bob',
  password  => 'pass',
  csrftoken => $t->csrftoken,
});

done_testing;

