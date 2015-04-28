package App::PAIA::Tester;
use strict;
use v5.10;

our $VERSION = '0.29';

use parent 'Exporter';
our @cmd = qw(stdout stderr output error exit_code);
our @EXPORT = (
    qw(new_paia_test paia_response done_paia_test paia debug), 
    qw(decode_json encode_json),
    @cmd);

use Test::More;
use App::Cmd::Tester;
use File::Temp qw(tempdir);
use Cwd;
use App::PAIA;
use JSON::PP;
use Scalar::Util qw(reftype);
use HTTP::Tiny;

our $CWD = getcwd();
our $RESULT;

eval "sub $_ { \$RESULT->$_ }" for @cmd; ## no critic

our $HTTP_TINY_REQUEST = \&HTTP::Tiny::request;

our $DEFAULT_PSGI = [ 500, [], ["no response faked yet"] ];
our $PSGI_RESPONSE = $DEFAULT_PSGI;
our $HTTP_REQUEST = sub { $PSGI_RESPONSE };

sub mock_http {
    my ($self, $method, $url, $opts) = @_;
    my $psgi = $HTTP_REQUEST->(
        $method, $url, $opts->{headers}, $opts->{content}
    );
    return {
        protocol => 'HTTP/1.1',
        status   => $psgi->[0],
        headers  => { @{$psgi->[1]} },
        content  => join "", @{$psgi->[2]},
    };
};

sub new_paia_test(@) { ## no critic
    my (%options) = @_;

    chdir tempdir();

    no warnings 'redefine';
    if ($options{mock_http}) {
        *HTTP::Tiny::request = \&mock_http;
    } else {
        no warnings;
        *HTTP::Tiny::request = $HTTP_TINY_REQUEST; 
    }
}

sub paia_response(@) { ## no critic
    $PSGI_RESPONSE = $DEFAULT_PSGI;
    if (ref $_[0] and reftype $_[0]  eq 'ARRAY') {
        $PSGI_RESPONSE = shift;
    } else {
        $PSGI_RESPONSE = $DEFAULT_PSGI;
        $PSGI_RESPONSE->[0] = $_[0] =~ /^\d+/ ? shift : 200;
        $PSGI_RESPONSE->[1] = shift if ref $_[0] and reftype $_[0] eq 'ARRAY' and @_ > 1;
        my $content = shift;
        if (reftype $content eq 'HASH') {
            push @{$PSGI_RESPONSE->[1]}, 'Content-type', 'application/json; charset=UTF-8';
            $PSGI_RESPONSE->[2] = [ encode_json($content) ];
        } elsif (reftype $_[1] eq 'ARRAY') {
            $PSGI_RESPONSE->[2] = $content;
        } else {
            $PSGI_RESPONSE->[2] = [$content];
        }
    }
}

sub paia(@) { ## no critic
    $RESULT = test_app('App::PAIA' => [@_]);
}

sub done_paia_test {
    chdir $CWD;
    done_testing;
}

sub debug {
    say "# $_" for split "\n", join "\n", (
        "stdout: ".$RESULT->stdout,
        "stderr: ".$RESULT->stderr,
        "error: ".$RESULT->error // 'undef',
        "exit_code: ".$RESULT->exit_code
    );
}

1;
__END__

=head1 NAME

App::PAIA::Tester - facilitate PAIA client testing

=head1 SYNOPSIS

    use Test::More;
    use App::PAIA::Tester;

    new_paia_test;

    paia qw(config base http://example.org/);
    is error, undef;

    paia qw(config);
    is_deeply stdout_json, {
        base => 'http://example.org/'
    };

    paia qw(login -u alice -p 1234);
    is stderr, '';
    is exit_code, 0;

    my $token = stdout_json->{access_token};
    ok $token;

    done_paia_test;

=head1 DESCRIPTION

The module implements a simple a singleton wrapper around L<App::Cmd::Tester>
to facilitate writing tests for and with the paia client L<App::PAIA>. 

=cut
