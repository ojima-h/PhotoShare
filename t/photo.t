use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]{test}{db},
}, qw/ Photo /;

my $t = Test::Mojo->new('PhotoShare');

$t->app->model->User->create(
  name => 'user',
  email => 'user@example.com',
  password => 'secret',
);

my $token;
$t->app->hook(after_render => sub {
                $token = shift->csrftoken;
              });
$t->ua->get('/login');
$t->ua->post('/sessions', form => {name => 'user', password => 'secret', csrftoken => $token});

#
# Upload
#
$t->ua->post('/photos',
             form => {'photo-data' => [ {file => "$FindBin::Bin/images/mojo.png"},
                                        {file => "$FindBin::Bin/images/camel.png"} ],
                      csrftoken => $token});

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
