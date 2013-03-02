package Test::PhotoShare;

use Exporter 'import';

use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

push our @ISA, 'Test::Mojo';

use File::Spec;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => 'dbi:SQLite:dbname=./share/photosharemodel-schema-test.db',
  connect_opts => { sqlite_uncode => 1 },
}, qw/ User Group Event Photo /;

our @EXPORT = qw(fixtures_ok change_ok User Group Event Photo);

sub new {
  my $self = shift->SUPER::new(@_);

  $self->{__PHOTO_SHARE_csrftoken}    = '';
  $self->{__PHOTO_SHARE_current_user} = undef;
  $self->{__PHOTO_SHARE_stash}        = undef;

  $self->app->hook(after_dispatch => sub {
                  my $_self = shift;
                  $self->{__PHOTO_SHARE_csrftoken}    = $_self->csrftoken;
                  $self->{__PHOTO_SHARE_current_user} = $_self->current_user;
                  $self->{__PHOTO_SHARE_stash}        = $_self->stash;
                });

  $self;
};

sub csrftoken    { shift->{__PHOTO_SHARE_csrftoken} }
sub current_user { shift->{__PHOTO_SHARE_current_user} }
sub stash        { shift->{__PHOTO_SHARE_stash} }

sub prepare_user {
  shift->app->model->User->create(@_);
}

sub redirect_ok {
  my ($self, $path) = @_;

  my $code = $self->tx->res->code;
  my $url  = $self->tx->res->headers->header('Location');

  my $path_got = $url ? Mojo::URL->new($url)->path : '';

  local $Test::Builder::Level = $Test::Builder::Level + 1;
  $self->_test('is', "$code: $path_got",
                     "302: $path",
               "redirect to $path",
             );

  return $self;
}

sub login_ok {
  my ($self, $name, $password) = @_;

  my $result = eval {
    my ($err, $code);
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # GET /login
    $self->tx($self->ua->get('/login'));
    ($err, $code) = $self->tx->error;

    die unless !$err || $code;
    die unless $self->tx->res->code == 200;

    # POST /sessions
    $self->tx($self->ua->post('/sessions', form => {
      name => $name,
      password => $password,
      csrftoken => $self->csrftoken,
    }));
    ($err, $code) = $self->tx->error;

    die unless !$err || $code;
    die unless  $self->tx->res->code == 302;

    $self->current_user;
  };

  $self->_test('ok', $result, 'login');

  $self;
}

sub logout_ok {
  my $self = shift;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  $self->get_ok('/logout');
  $self;
}

sub change_ok {
  my ($exp, $count, $operation) = @_;

  my $before = $exp->();
  $operation->();
  my $after =  $exp->();

  local $Test::Builder::Level = $Test::Builder::Level + 1;
  is($after, $before + $count, "Expected changes occurred");
}

sub upload_photos {
  my $self = shift;
  my @photo_data = map { {file => File::Spec->catfile($ENV{MOJO_APP_ROOT}, '/../t/images/', $_)} } @_;

  $self->get_ok('/photos/new')->status_is(200);
  $self->post_ok('/photos',
                   form => {'photo-data' => \@photo_data,
                            csrftoken => $self->csrftoken});

  $self;
}

sub set_passphrase {
  my ($self, $event, $passphrase) = @_;

  $event->passphrase($passphrase);
  $event->update;
}

1;

__END__

=encoding utf-8

=head1 NAME

Test::PhotoShare - Test utilities for PhotoShare app.

=head1 SYNOPSIS

  my $t = Test::PhotoShare->new('PhotoShare');

  $t->prepare_user(
    name => 'user',
    email => 'user@example.com',
    password => 'secret',
  );

  $t->login_ok('user', 'secret');

  $t->get_ok('/photos/new')
    ->status_is(200)
    ->element_exists('form');

  change_ok(sub { Photo->count }, 2,
            sub {
              $t->post_ok('/photos',
                          form => {
                            'photo-data' => [ {file => $ENV{MOJO_APP_ROOT} . "/../t/images/mojo.png"},
                                              {file => $ENV{MOJO_APP_ROOT} . "/../t/images/camel.png"} ],
                            csrftoken => $t->csrftoken
                          })
                ->redirect_to(qr#http://localhost:\d+/photos$#);
            });

=head1 DESCRIPTION

PhotoShare用のテストユーティリティを提供します。

Test::PhotoShare を継承してます。

インクルードされたときに、L<Test::DBIx::Class> をインクルードし、データベースとの接続を確立します。
各テーブルのSchemaと C<Test::DBIx::Class::fixture_ok> をエクスポートします。

=head1 METHODS

=head2 new

  my $t = Test::PhotoShare->new('PhotoShare')

=head2 csrftoken

  $t->csrftoken

L<Test::PhotoShare> は、リクエストがある度、CSRF対策のためのトークンを取得します。

=head2 current_user

L<Test::PhotoShare> は、リクエストがある度、現在のユーザを取得します。
ログインしていない状態であれば、C<undef> を返します。

=head2 prepare_user

=head2 login_ok

=head2 upload_photos

  $t->upload_photos('photo_1.png', 'photo_2.jpg');

C<t/images> 以下から写真データを検索してアップロードします

=head2 change_ok

  change_ok(exp, num, operation);

C<exp> と C<operation> はコードレフです。

C<operation> 実行前後で、C<exp> を評価した結果が C<num> だけ違うことを確かめます。
