use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]{test}{db},
};

my $t = Test::Mojo->new('PhotoShare');

my $token;
$t->app->hook(after_render => sub {
                    $token = shift->csrftoken;
                  });

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
                                csrftoken => $token,
                               })
  ->status_is(302)
  ->header_like(Location => qr#http://localhost:\d+/login/?$#);

$t->get_ok('/login');
my $user;
$t->app->hook(after_dispatch => sub {
               $user = shift->current_user;
             });
$t->post_ok('/sessions', form => {
  name      => 'bob',
  password  => 'pass',
  csrftoken => $token,
});
ok $user;
ok $user->default_group;
ok $user->default_group->default_event;;

done_testing;

