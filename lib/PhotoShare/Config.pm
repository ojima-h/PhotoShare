package PhotoShare::Config;
use strict;
use warnings;

our %default_config = (
  session_key => 'wickedapp',
  db => {
    dsn => "dbi:SQLite:$FindBin::Bin/../db/development.sqlite3"
  },
);

sub load {
  my $class = shift;
  my $app   = shift;
  my $config_file = "$FindBin::Bin/../config.yml";

  use YAML::Tiny;

  if ( -f $config_file ) {
    my $config = YAML::Tiny->read("$FindBin::Bin/../config.yml")->[0]
      or die 'Failed to load configuration file.';

    for my $key (keys %default_config) {
      $app->config->{$key} = $default_config{$key};
    }
    for my $key (keys %$config) {
      $app->config->{$key} = $config->{$key};
    }
  }
}

1;
