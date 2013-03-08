package PhotoShare::Signup;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw/md5_sum/;

use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;

sub confirm {
  my $self = shift;

  my ($name, $email, $password, $password_confirm) = $self->param([qw/ name email password password-confirm/]);

  unless ($password eq $password_confirm) {
    $self->flash('alert-error' => 'パスワードが一致しません');
    return $self->redirect_to('/signup');
  }

  my $token = _generate_token();

  $self->session(signup_info => {
    name     => $name,
    email    => $email,
    password => $password,
    token    => $token,
  });

  $self->_send_confirmation_email($name, $email, $token);

  $self->redirect_to('/signup/confirm-email');
}

sub confirm_email {
  my $self = shift;

  $self->redirect_to('/signup') unless $self->_is_user_info_registered;

  $self->render('/signup/confirm_email');
}

sub _generate_token {
  md5_sum( md5_sum( time() . {} . rand() . $$ ) );
}


sub _send_confirmation_email {
  my ($self, $name, $address, $token) = @_;

  my $confirm_url = $self->url_for('/users/create')->query(token => $token)->to_abs;

  my $email = Email::Simple->create(
    header => [
      To      => $address,
      From    => '"Photo Share" <ojima.h@magomiru.jp>',
      Subject => "${name}さん、PhotoShareアカウントを確認してください!",
    ],
    body => <<EOM,
こんにちは、${name}さん。

以下のアドレスをクリックすることにより、PhotoShareアカウントの登録確認が完了します:
${confirm_url}
EOM
  );

  my $transport = Email::Sender::Transport::SMTP->new({
    host => 'smtp.gmail.com',
    port => 465,
    ssl  => 1,
    sasl_username => $self->config('email_sender')->{user},
    sasl_password => $self->config('email_sender')->{password},
  });

  eval { sendmail($email, { transport => $transport }); };
  if ($@) {
    my $error = $@; warn $error->message;
    return 0;
  }

  return 1;
}

sub _is_user_info_registered {
  my $self = shift;

  $self->session('signup_info');
}

1;
