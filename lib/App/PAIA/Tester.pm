#ABSTRACT: Facilitate PAIA client unit tests
package App::PAIA::Tester;
use strict;
use v5.10;
#VERSION

use parent 'Exporter';
our @cmd = qw(stdout stderr output error exit_code);
our @EXPORT = (qw(new_paia_test done_paia_test paia stdout_json debug), @cmd);

use Test::More;
use App::Cmd::Tester;
use JSON::PP;
use File::Temp qw(tempdir);
use Cwd;
use App::PAIA;

our $CWD = getcwd();
our $RESULT;

eval "sub $_ { \$RESULT->$_ }" for @cmd; ## no critic

sub stdout_json {
    decode_json($RESULT->stdout);
}

sub new_paia_test {
    chdir tempdir();

    my %options = @_;
    if ($options{http_request}) { # Mock HTTP(S) requests
        require HTTP::Tiny;
        no warnings;
        *HTTP::Tiny::request = sub {
            my ($self, $method, $url, $opts) = @_;
            my $psgi = $options{http_request}->(
                $method, $url, $opts->{headers}, $opts->{content}
            );
            return {
                protocol => 'HTTP/1.1',
                status   => $psgi->[0],
                headers  => { $psgi->[1] },
                content  => join "", @{$psgi->[2]},
            }
        };
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
to facilitate writing unit tests for the paia client L<App::PAIA>. 

=cut

1;
