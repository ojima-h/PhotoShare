package PhotoShare::Config;
use strict;
use warnings;

sub load {
  my $class = shift;
  my $app   = shift;
  my $config_file = "$FindBin::Bin/../config.yml";

  use YAML::Tiny;

  if ( -f $config_file ) {
    my $config = YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]
      or die 'Failed to load configuration file.';

    for my $key (keys %{ $config->{default} }) {
      $app->config->{$key} = $config->{default}{$key};
    }

    my $mode = $app->mode;
    for my $key (keys %{ $config->{$mode} }) {
      $app->config->{$key} = $config->{$mode}{$key};
    }
  }
}

1;
