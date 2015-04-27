package App::PAIA::Command::cancel;
use strict;
use v5.10;
use parent 'App::PAIA::Command';

sub description {
    "Cancels requests given by their item's (default) or edition's URI."
}

sub usage_desc {
    "%c cancel %o URI [item=URI] [edition=URI] ..."
}

sub _execute {
    my ($self, $opt, $args) = @_;

    my @docs = $self->uri_list(@$args);
    
    $self->usage_error("Missing document URIs to cancel")
        unless @docs;

    $self->core_request( 'POST', 'cancel', { doc => \@docs } );
}

1;
__END__

=head1 NAME

App::PAIA::Command:: - cancel requests

=cut
