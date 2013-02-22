use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]{test}{db},
}, qw/ Photo /;

subtest 'When not authenicated' => sub {
  plan skip_all => 'cuz I said so.';
  my $t = Test::Mojo->new('PhotoShare');

  $t->get_ok('/photos/new')
    ->status_is(302)
    ->header_like(Location => qr#http://localhost:\d+/login$#);
  $t->post_ok('/photos')
    ->status_is(302)
    ->header_like(Location => qr#http://localhost:\d+/login$#);
};

subtest 'When autheticated' => sub {
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

  $t->get_ok('/photos/new')
    ->status_is(200)
    ->element_exists('form[action=/photos]')
    ->element_exists('form input#photo-data');

  my $count = Photo->count;
  $t->post_ok('/photos',
              form => {'photo-data' => [ {file => "$FindBin::Bin/images/mojo.png"},
                                         {file => "$FindBin::Bin/images/camel.png"} ],
                       csrftoken => $token})
    ->status_is(200);
  is Photo->count, $count + 2;
};

done_testing;
