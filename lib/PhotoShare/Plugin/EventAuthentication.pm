package PhotoShare::Plugin::EventAuthentication;
use Mojo::Base 'Mojolicious::Plugin';

=head1 NAME

PhotoShare::Helper::EventAuthentication

PhotoShareにイベント毎のあいことば認証の機能を追加します。

=head1 SYNOPSIS

  package PhotoShare;

  sub startup {
    ...

    $self->plugin('PhotoShare::Plugin::EventAuthentication');
  }


  package PhotoShare::Events::Photos;

  sub action {
    ...

    $self->is_event_authorized($event);

    $self->authenticate_event($event, $passphrase);

    $self->is_event_authenticated($event);
  }

=cut

sub register {
  my ($self, $app, $conf) = @_;

  $app->helper(is_event_authorized => sub {
                 my ($controller, $event) = @_;

                 $controller->is_event_authenticated($event)
                   or ($controller->is_user_authenticated
                         and $controller->current_user->is_owner($event));
               });

  $app->helper(authenticate_event => sub {
                 my ($controller, $event, $passphrase) = @_;

                 $controller->session('Event-Auth' => {}) unless defined $controller->session('Event-Auth');

                 if (my $key = $event->validate($passphrase)) {
                   $controller->session('Event-Auth')->{$event->id} = $key;
                   1;
                 } else {
                   0;
                 }
               });

  $app->helper(is_event_authenticated => sub {
                 my ($controller, $event) = @_;

                 return 0 unless $controller->session('Event-Auth');

                 my $key = $controller->session('Event-Auth')->{$event->id};
                 return $event->is_valid_key($key);
               });
}

1;
