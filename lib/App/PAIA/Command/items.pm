#ABSTRACT: list loans, reservations and other items related to a patron
package App::PAIA::Command::items;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

use App::PAIA::JSON;

sub execute {
    my ($self, $opt, $args) = @_;

    my $response = $self->core_request('GET', 'items');
    print encode_json($response);
}

1;
