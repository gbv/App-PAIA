#ABSTRACT: HTTP client wrapper
package App::PAIA::Agent;
use v5.14;
#VERSION

use HTTP::Tiny 0.018; # core module 0.012 does not support verify_SSL
use URI;
use App::PAIA::JSON;

sub new {
    my ($class, %options) = @_;
    bless {
        agent   => HTTP::Tiny->new( verify_SSL => (!$options{insecure}) ),
        verbose => !!$options{verbose},
        quiet   => !!$options{quiet},
    }, $class;
}

sub request {
    my $self    = shift;
    my $method  = shift;
    my $url     = URI->new(shift);
    my $param   = shift // {};
    my $headers = { 
        Accept => 'application/json',
        @_ 
    };
    my $content;

    say "# $method $url" unless $self->{quiet};

    if ($method eq 'POST') {
        $headers->{'Content-Type'} = 'application/json';
        $content = encode_json($param);
    } elsif (%$param) {
        $url->query_form(%$param);
    }

    $self->show_request( $method, $url, $headers, $content );
    my $response = $self->{agent}->request( $method, $url, {
        headers => $headers,
        content => $content    
    } );
    say "> " if $self->{verbose};
    $self->show_response( $response );
   
    return $response if $response->{status} eq '599';

    my $json = eval { decode_json($response->{content}) };
    if (my $e = "$@") {
        return {
            url => "$url",
            success => q{},
            status  => 599,
            reason  => 'Internal Exception',
            content => $e,
            headers => {
                'content-type'   => 'text/plain',
                'content-length' => length $e,
            }
        };
    }

    return ($response, $json);
}

sub show_request {
    my ($self, $method, $url, $headers, $content) = @_;
    return unless $self->{verbose};

    say "> $method " . $url->path_query . " HTTP/1.1";
    say "> Host: " . $url->host;
    $self->show_message( $headers, $content );
}

sub show_response {
    my ($self, $res) = @_;
    return unless $self->{verbose};

    printf "> %s %s\n", $res->{protocol}, $res->{status};
    $self->show_message( $res->{headers}, $res->{content} );
}

sub show_message {
    my ($self, $headers, $content) = @_;

    while (my ($header, $value) = each %{$headers}) {
        $value = join ", ", @$value if ref $value;
        say "> " . ucfirst($header) . ": $value";
    }
    if (defined $content) {
        say "> ";
        say "> $_" for split "\n", $content;
    }
}

1;

=head1 DESCRIPTION

This class implements a HTTP client by wrapping L<HTTP::Tiny>. The client
expects to send JSON on HTTP POST and to receive JSON as response content.

=head1 OPTIONS

=over

=item insecure

disables C<verfiy_SSL>.

=item verbose

enables output of request and response.

=item quiet

disables output of HTTP method and URL before each request.

=back

=cut
