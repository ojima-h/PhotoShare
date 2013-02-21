use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]{test}{db},
};

my $t = Test::Mojo->new('PhotoShare');

$t->get_ok('/signup')
  ->status_is(200)
  ->element_exists('form#signup_form input[name=name]')
  ->element_exists('form#signup_form input[name=password]')
  ->element_exists('form#signup_form input[name=password-confirm]')
  ->element_exists('form#signup_form input[name=email]');

my $token = $t->tx->res->dom->at('form#signup_form input[name=csrftoken]')->attrs('value');

$t->post_ok('/users', form => { name => 'bob',
                                 password => 'pass',
                                 'password-confirm' => 'pass',
                                 email => 'test@example.com',
                                 csrftoken => $token,
                               })
  ->status_is(302)
  ->header_like(Location => qr#http://localhost:\d+/login/?$#);

done_testing;

