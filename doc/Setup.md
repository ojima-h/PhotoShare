How to Install
--------

1.  Install perlbrew.

    >   ref. <http://perlbrew.pl/>

2.  Install perl-5.12.5.

        $ perlbrew install 5.12.5

3.  Create local::lib instance.

        $ perlbrew lib create perl-5.12.5@photo-share
        $ perlbrew use perl-5.12.5@photo-share
        
4.  Install cpan modules.

        $ cpanm <Module Name>

    Modules are:

    -   Mojolicious
    -   DBIx::Class
    -   DBIx::Class::Schema::Loader
    -   DBIx::Migration
    -   Mojolicious::Plugin::TagHelpers
    -   Mojolicious::Plugin::Authentication
    -   Mojolicious::Plugin::CSRFProtect
    
    
