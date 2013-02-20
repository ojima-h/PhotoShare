use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Test::DBIx::Class {
  schema_class => 'Schema',
  connect_info => ['dbi:SQLite:dbname=./db/test.sqlite3','',''],
};

my $t = Test::Mojo->new('PhotoShare');
$t->app->config->{db}{dsn} = 'dbi:SQLite:dbname=./db/test.sqlite3';

fixtures_ok [
  User => [
    [qw/ name password /],
    [qw/ bob secret /],
  ],
];

$t->ua->max_redirects(0);

$t->get_ok('/login')
  ->status_is(200)
  ->element_exists('form[action=/sessions]')
  ->element_exists('form input#name')
  ->element_exists('form input#password');

my $token = $t->tx->res->dom->at('form#login_form input[name=csrftoken]')->attrs('value');
$t->post_ok('/sessions', form => { name => 'bob', password => 'secret', csrftoken => $token })
  ->status_is(302)
  ->header_like(Location => qr#http://localhost:\d+/$#);

$t->get_ok('/login');
$token = $t->tx->res->dom->at('form#login_form input[name=csrftoken]')->attrs('value');
$t->post_ok('/sessions', form => { name => 'bob', password => 'wrong', csrftoken => $token })
  ->status_is(302)
  ->header_like(Location => qr#http://localhost:\d+/login/?$#);

# $t->delete_ok('/sessions')
#   ->status_is(200)
#   ->text_is('#message' => 'logout');
$t->ua->max_redirects(1);
$t->get_ok('/logout')
  ->status_is(200)
  ->text_is('#message' => 'ログアウトしました')
  ->text_isnt('ul.nav li:last-child a' => 'Logout');    # 実際にログアウトしたことを確認

done_testing();








