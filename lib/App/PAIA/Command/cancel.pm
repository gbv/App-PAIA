#ABSTRACT: cancel requests
package App::PAIA::Command::cancel;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub description {
    "Cancels requests given by their item's (default) or edition's URI."
}

sub usage_desc {
    "%c cancel %o URI [item=URI] [edition=URI] ..."
}

sub execute {
    my ($self, $opt, $args) = @_;

    my @docs = $self->uri_list(@$args);
    
    $self->usage_error("Missing document URIs to cancel")
        unless @docs;

    my $response = $self->core_request( 'POST', 'cancel', { doc => \@docs } );
    say encode_json($response);
}

1;
