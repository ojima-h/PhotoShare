package Test::PhotoShare;

use base qw(Exporter Class::Delegate);

use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use File::Spec;

use Test::PhotoShare::Helper;

use YAML::Tiny;
use Test::DBIx::Class {
  schema_class => 'PhotoShareModel::Schema',
  connect_info => 'dbi:SQLite:dbname=./share/photosharemodel-schema-test.db',
  connect_opts => { sqlite_uncode => 1 },
}, qw/ User Group Event Photo /;

our @EXPORT = qw(fixtures_ok change_ok User Group Event Photo);

sub new {
  my $class = shift;
  my $t = Test::Mojo->new(@_);

  my $self = bless {
    t    => $t,
    csrftoken    => '',
    current_user => undef,
    stash        => undef,
  };

  $t->app->hook(after_dispatch => sub {
                  my $_self = shift;
                  $self->{csrftoken}    = $_self->csrftoken;
                  $self->{current_user} = $_self->current_user;
                  $self->{stash}        = $_self->stash;
                });

  $self->add_delegate($t);
};

sub csrftoken    { shift->{csrftoken} }
sub current_user { shift->{current_user} }
sub stash        { shift->{stash} }

sub prepare_user {
  shift->app->model->User->create(@_);
}

sub login_ok {
  my ($self, $name, $password) = @_;

  $self->get_ok('/login')->status_is(200);

  $self->post_ok('/sessions', form => {
    name => $name,
    password => $password,
    csrftoken => $self->csrftoken,
  });

  ok $self->current_user;

  $self;
}

sub logout_ok {
  my $self = shift;
  $self->get_ok('/logout');
  $self;
}

sub change_ok {
  my ($exp, $count, $operation) = @_;

  my $before = $exp->();
  $operation->();
  my $after =  $exp->();

  is $after, $before + $count, "Expected changes occurred";
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

いくつかのメソッドを除き、ほとんどのメソッドの呼び出しは L<Test::Mojo>
のインスタンスに移譲されます。

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
