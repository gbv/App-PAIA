package App::PAIA::JSON;
use v5.14;
#VERSION

use base 'Exporter';
our @EXPORT = qw(decode_json encode_json);
use JSON::PP qw();    # core module

sub decode_json {
    my $json = shift;
    my $data = eval { JSON::PP->new->utf8->relaxed->decode($json); };
    if ($@) {
        my $msg = reverse $@;
        $msg =~ s/.+? ta //sm;
        $msg = "JSON error: " . scalar reverse($msg);
        $msg .= " in " . shift if @_;
        die $msg;
    }
    return $data;
}

sub encode_json {
    JSON::PP->new->utf8->pretty->encode($_[0]); 
}

1;

=head1 DESCRIPTION

This class wraps and exports method C<encode_json> and C<decode_json> from
L<JSON::PP>. On encoding JSON is pretty-printed. Decoding is relaxed and
with better error message on failure.

=cut
