#ABSTRACT: get general patron information
package App::PAIA::Command::patron;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->core_request( 'GET', 'patron' );
}

1;
