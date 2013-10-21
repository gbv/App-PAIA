#ABSTRACT: invalidate an access token
package App::PAIA::Command::logout;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

sub execute {
    my ($self, $opt, $args) = @_;

    if (defined $self->session_file) {
        $self->session;
        unlink $self->session_file;
    }

    die "Not fully implemented yet!\n";
}

1;
