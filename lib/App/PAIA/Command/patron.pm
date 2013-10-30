#ABSTRACT: get general patron information
package App::PAIA::Command::patron;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->core_request( 'GET', 'patron' );
    print encode_json($response);
}

1;
