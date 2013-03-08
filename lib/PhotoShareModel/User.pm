package PhotoShareModel::User;
use strict;
use warnings;

use base 'PhotoShareModel::Base';

use Mojo::Util qw(md5_sum);
use Digest::SHA1 qw/sha1_base64/;

our $STRETCH_COUNT = 100;

=head1 NAME

PhotoShareModel::User

=head1 SYNOPSIS

L<PhotoShareModel::Photo> 参照

=cut

=head1 METHODS

=head2 new($app, $photo_id)
$app     -- L<PhotoShareModel> instance.
$user_id -- user id in the database. (optional)

=cut

sub _table_name { 'User' }

# Delegating Methods
sub id         { shift->_result->id(@_) }
sub name       { shift->_result->name(@_) }
sub email      { shift->_result->email(@_) }
sub password   { shift->_result->password(@_) }
sub groups     { shift->_result->groups(@_) }
sub events     { shift->_result->events(@_) }
sub photos     { shift->_result->photos(@_) }
sub default_group { shift->_result->default_group(@_) }

=head2 create

detault_group, defalt_event も同時につくります

=cut

sub create {
  my $self = shift;
  my %param = @_;
  my ($name, $email, $password) = ($param{name}, $param{email}, $param{password});

  my $hashed_password = $self->_get_password_hash($name, $password);

  my $user = $self->db('User')->create({
    name     => $name,
    email    => $email,
    password => $hashed_password,
  });
  my $default_group = $self->app->Group->create(
    name => "default: " . $param{name},
  );

  $user->add_to_groups($default_group);
  $user->default_group($default_group);
  $user->update;
}

=head2 validate( name => $name, password => password )

authentication に使用します。

password があっていれば、user id を返します。

=cut

sub validate {
  my ($self, %args) = @_;
  my ($name, $password) = ($args{name}, $args{password});

  my $hashed_password = $self->_get_password_hash($name, $password);

  my $user = $self->db('User')->search({
        name => $name,
        password => $hashed_password
      })->first;

  $user ? $user->id : undef;
}

sub is_owner {
  my ($self, $event) = @_;

  $self->events->find($event->id);
}

=head2 exists

指定された name や email を持つユーザが存在すれば、真値を返します。

  $user->exists(name => 'foo');
  $user->exists(email => 'bar');

=cut

sub exists {
  my ($self, %args) = @_;

  if (my $name = $args{name}) {
    return $self->db('User')->find({
      name => $name,
    });
  }
  if (my $email = $args{email}) {
    return $self->db('User')->find({
      email => $email,
    });
  }

  0;
}

sub _get_password_hash {
  my ($self, $id, $password) = @_;
  my $salt = $self->_salt($id);

  my $hash = '';
  for (0..$STRETCH_COUNT) {
    $hash = sha1_base64($hash . $password . $salt);
  }

  $hash
}

sub _salt {
  my ($self, $id) = @_;
  my $salt = md5_sum $self->app->config('session_key');

  $id . $salt;
}

1;
