#ABSTRACT: get a access token and patron identifier
package App::PAIA::Command::login;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub description {
    "requests or renews an access_token from a PAIA auth server."
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->login( $self->explicit_option('scope') );
    print encode_json($response);
}

1;
