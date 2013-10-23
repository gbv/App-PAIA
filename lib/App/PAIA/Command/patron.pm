#ABSTRACT: get general patron information
package App::PAIA::Command::patron;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->core_request( 'GET', 'patron' );
    say encode_json($response);
}

1;
