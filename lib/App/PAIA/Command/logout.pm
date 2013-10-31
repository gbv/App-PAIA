#ABSTRACT: invalidate an access token
package App::PAIA::Command::logout;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub _execute {
    my ($self, $opt, $args) = @_;

    my $auth = $self->auth // $self->usage_error("missing PAIA auth URL");

    my $response = $self->request( 
        "POST", "$auth/logout", { patron => $self->patron }
    );
    print encode_json($response);

    if (defined $self->session->file) {
        $self->session;
        unlink $self->session->file;
        $self->log("deleted session file");
    }

    return;
}

1;
