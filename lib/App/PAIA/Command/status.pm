#ABSTRACT: show current session status
package App::PAIA::Command::status;
use parent 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub description {
    "This command shows the current configuration and session";
}

sub execute {
    my ($self, $opt, $args) = @_;

    if (defined $self->config_file) {
        say "configuration from ".$self->config_file.":";
        print encode_json($self->config);
    } else {
        say "no configuration.";
    }

    if (defined $self->session_file) {
        say "session from ".$self->session_file.":";
        print encode_json($self->session);
        print "not " unless $self->authentificated( verbose => 1 );
        say "authentificated.";
    } else {
        say "no session.";
    }

    say "base URL: ".$self->base if defined $self->base;
    say "auth URL: ".$self->auth if defined $self->auth;
    say "core URL: ".$self->core if defined $self->core;
}

1;
