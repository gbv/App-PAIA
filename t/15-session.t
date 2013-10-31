use strict;
use v5.10;
use Test::More;
use App::PAIA::Tester;

new_paia_test;

paia 'session';
is error, "no session file found.\n", "no session file";

# TODO: more tests

done_paia_test;
