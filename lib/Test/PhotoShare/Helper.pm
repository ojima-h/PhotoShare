package Test::PhotoShare::Helper;

{
  package Test::Mojo;

  sub redirect_to {
    my ($self, $url) = @_;

    $self->status_is(302)
      ->header_like(Location => $url);
  }
}


1;
