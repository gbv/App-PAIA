#ABSTRACT: get a access token and patron identifier
package App::PAIA::Command::login;
use base 'App::PAIA::Command';
use v5.14;

use Data::Dumper;

sub opt_spec {
    ["username:s"=>"username or -number for login"],
    ["password:s"=>"password for login"],
    ["scopes:s"=>"comma-separated list of scopes"];
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->login( 
        username => ($opt->username // $self->config->{username}),
        password => ($opt->password // $self->config->{password}),
        scopes   => ($opt->scopes // $self->config->{scopes}),
    );

    say $self->json($response);
}

1;
