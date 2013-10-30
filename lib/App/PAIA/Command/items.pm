#ABSTRACT: list loans, reservations and other items related to a patron
package App::PAIA::Command::items;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->core_request('GET', 'items');
}

1;
