package PhotoShareModel::Config;
use strict;
use warnings;

sub load {
  my $class = shift;
  my $mode  = shift;
  my $config_file = "./config.yml";
  my %config;

  if ( -f $config_file ) {
    use YAML::Tiny;
    my $config = YAML::Tiny->read($config_file)->[0]
      or die 'Failed to load configuration file.';

    for my $key (keys %{ $config->{default} }) {
      $config{$key} = $config->{default}{$key};
    }

    for my $key (keys %{ $config->{$mode} }) {
      $config{$key} = $config->{$mode}{$key};
    }
  }

  return \%config;
}

1;
