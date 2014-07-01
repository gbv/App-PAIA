use strict;
use v5.10;
use Test::More;
use App::PAIA::Tester;

new_paia_test mock_http => 1;

# no session
paia 'session';
is error, "no session file found.\n", "no session file";

# auto-login
paia_response 200, [ ], {
  access_token => "2YotnFZFEjr1zCsicMWpAA",
  token_type => "Bearer",
  expires_in => 3600,
  patron => "8362432",
  scope => "read_patron read_fees read_items write_items"
};

paia qw(patron -b https://example.org/ -u alice -p 1234 -v -q);
is output, <<OUT;
# auto-login with scope 'read_patron'
# POST https://example.org/auth/login
# saved session file paia-session.json
# GET https://example.org/core/8362432
OUT

# TODO: more tests

done_paia_test;
