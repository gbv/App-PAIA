#ABSTRACT: Renew one or more documents held by a patron
package App::PAIA::Command::renew;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub description {
    "Renews documents given by their item's (default) or edition's URI."
}

sub usage_desc {
    "%c renew %o URI [item=URI] [edition=URI] ..."
}

sub execute {
    my ($self, $opt, $args) = @_;

    my @docs = $self->uri_list(@$args);
    
    $self->usage_error("Missing document URIs to cancel")
        unless @docs;

    my $response = $self->core_request( 'POST', 'renew', { doc => \@docs } );
    print encode_json($response);
}

1;
