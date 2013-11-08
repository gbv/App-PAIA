use strict;
use v5.10;
use Test::More;
use App::PAIA::Tester;
use App::PAIA::JSON qw(encode_json);

new_paia_test 
    http_request => sub {
        my ($method, $url, $headers, $content) = @_;
        [ 403, [ 
            'Content-type' => 'application/json; charset=UTF-8' 
            ], [ encode_json {
                error => 'access_denied',
                code  => 403,
                error_description => 'invalid patron or password'
            } ]
        ]
    };

paia qw(login -b https://example.org -u alice -p 1234 -v);

is output, "# POST https://example.org/auth/login\n";
is error, "access_denied: invalid patron or password\n";
ok exit_code;

done_paia_test;
