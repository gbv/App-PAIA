#ABSTRACT: list fees
package App::PAIA::Command::fees;
use strict;
use v5.10;
use base 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->core_request('GET', 'fees');
    print encode_json($response);
}

1;
