package PhotoShareModel::Config;
use strict;
use warnings;

sub load {
  my $class = shift;
  my $mode  = shift;
  my $config_file = $ENV{MOJO_CONFIG_FILE};
  my %config;

  if ( -f $config_file ) {
    use YAML::Tiny;
    my $config = YAML::Tiny->read($config_file)
      or die "Failed to load configuration file: " . YAML::Tiny->errstr;
    $config = $config->[0];

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
