use strict;
use warnings;
use v5.10;
use Test::More;
use App::Cmd::Tester;
use App::PAIA;
use File::Temp qw(tempdir);
use Cwd;
use JSON::PP;

my $cwd = getcwd();
my $dir = tempdir();
chdir $dir;

my $res;
sub paia(@) { ## no critic
    $res = test_app('App::PAIA' => [@_]);
}

# let's start in an empty directory

paia 'session';
is $res->error, "no session file found.\n", "no session file";

paia 'config';
is $res->stdout, "{}\n", "empty configuration";
is $res->error, undef;

paia qw(config --ini);
is $res->stdout, "", "empty configuration (ini)";
is $res->error, undef;

paia qw(config -c x.json --verbose);
is $res->error, "failed to open config file x.json\n", "missing config file";

# add configuration values

paia qw(config --config x.json --verbose foo bar);
is $res->output, "# saved config file x.json\n", "created config file";

paia qw(config foo bar);
paia qw(config base http://example.org/);
is $res->exit_code, 0, "set config value";
is $res->output, '';

paia qw(config base);
is $res->stdout, "http://example.org/\n", "get config value";

paia qw(config);
is_deeply decode_json($res->stdout), { 
    base => 'http://example.org/',
    foo => 'bar',
}, "get full config";

paia qw(config -i);
is $res->output, "base=http://example.org/\nfoo=bar\n", "full config (ini)";

paia qw(config -d foo);
is $res->output, '', 'unset config value';

paia qw(config foo);
is $res->exit_code, 1, "config value not found";

chdir $cwd;

done_testing;
