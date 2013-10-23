#ABSTRACT: Renew one or more documents held by a patron
package App::PAIA::Command::renew;
use base 'App::PAIA::Command';
use v5.14;
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
    say encode_json($response);
}

1;
