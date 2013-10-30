#ABSTRACT: list fees
package App::PAIA::Command::fees;
use strict;
use v5.10;
use base 'App::PAIA::Command';
#VERSION

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->core_request('GET', 'fees');
}

1;
