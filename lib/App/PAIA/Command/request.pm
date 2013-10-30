#ABSTRACT: request one or more items for reservation or delivery
package App::PAIA::Command::request;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

sub usage_desc {
    "%c request %o URI [item=URI] [edition=URI] ..."
    # storage not supported yet
}

sub execute {
    my ($self, $opt, $args) = @_;

    my @docs = $self->uri_list(@$args);
    
    $self->usage_error("Missing document URIs to request")
        unless @docs;

    $self->core_request( 'POST', 'request', { doc => \@docs } );
}

1;
