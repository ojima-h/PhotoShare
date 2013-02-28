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
}, qw/ User Group Event Photo /;

our @EXPORT = qw(fixtures_ok change_ok User Group Event Photo);

sub new {
  my $class = shift;
  my $t = Test::Mojo->new(@_);

  my $self = bless {
    t    => $t,
    csrftoken => '',
    current_user => undef,
  };

  $t->app->hook(after_render => sub {
                  $self->{csrftoken} = shift->csrftoken;
                });
  $t->app->hook(after_dispatch => sub {
                  $self->{current_user} = shift->current_user;
                });

  $self->add_delegate($t);
};

sub csrftoken    { shift->{csrftoken} }
sub current_user { shift->{current_user} }

sub prepare_user {
  shift->app->model->User->create(@_);
}

sub login_ok {
  my ($self, $name, $password) = @_;

  $self->get_ok('/login');

  $self->post_ok('/sessions', form => {
    name => $name,
    password => $password,
    csrftoken => $self->csrftoken
  });
}

sub change_ok {
  my ($exp, $count, $operation) = @_;

  my $before = $exp->();
  $operation->();
  my $after =  $exp->();

  is $after, $before + $count, "Expected changes occurred"
}

1;
