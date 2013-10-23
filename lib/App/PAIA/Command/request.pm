#ABSTRACT: request one or more items for reservation or delivery
package App::PAIA::Command::request;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub usage_desc {
    "%c request %o URI [item=URI] [edition=URI] ..."
    # storage not supported yet
}

sub execute {
    my ($self, $opt, $args) = @_;

    my @docs = $self->uri_list(@$args);
    
    $self->usage_error("Missing document URIs to request")
        unless @docs;

    my $response = $self->core_request( 'POST', 'request', { doc => \@docs } );
    print encode_json($response);
}

1;
