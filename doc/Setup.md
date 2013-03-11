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
    -   Mojolicious::Plugin::Authentication
    -   YAML::Tiny
    -   Test::DBIx::Class   <- めっちゃでかい
    -   File::MMagic
    -   Email::Sender::Transport::SMTP
    -   Authen::SASL
    -   MIME::Base64
    -   IO::Scalar
    -   Digest::SHA1

5.  Copy /config.yml.example to /config.yml.

    email_sender に user と password を適当なSMTPサーバの
    ユーザ名とパスワードに書き換える。
    
6.  データベースのスキーマを読み込みます

        $ ./script/migrate install
    
6.  テストを走らせます。

        $ ./script/photo_share test
        
    テストが通れば、ひとまずオッケーです。
