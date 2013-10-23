#ABSTRACT: invalidate an access token
package App::PAIA::Command::logout;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub execute {
    my ($self, $opt, $args) = @_;

    my $auth = $self->auth // $self->usage_error("missing PAIA auth URL");

    my $response = $self->request( 
        "POST", "$auth/logout", { patron => $self->patron }
    );
    print encode_json($response);

    if (defined $self->session_file) {
        $self->session;
        unlink $self->session_file;
        $self->log("deleted session file");
    }
}

1;
