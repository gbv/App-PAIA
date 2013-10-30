#ABSTRACT: show current session status
package App::PAIA::Command::session;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub description {
<<MSG
This command shows the current PAIA auth session.
The exit code indicates whether a session file was found with not-expired
access token and PAIA server URLs. Options --verbose|-v enables details.
MSG
}

sub _execute {
    my ($self, $opt, $args) = @_;

    if (defined $self->session->file ) {
        say encode_json($self->session) if $self->verbose;
        my $msg = $self->not_authentificated;
        die "$msg.\n" if $msg;
        say "session looks fine.";
    } else {
        die "no session file found.\n";
    }

    if (!$self->auth) {
        die "PAIA auth server URL not found\n";
    } else {
        $self->log('auth URL: '.$self->auth);
    }

    if (!$self->core) {
        die "PAIA core server URL not found\n";
    } else {
        $self->log('core URL: '.$self->core);
    }

    return;
}

1;