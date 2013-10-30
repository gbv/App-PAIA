use strict;
use warnings;
use v5.10;
use Test::More;
use App::Cmd::Tester;
use App::PAIA;
use File::Temp qw(tempdir);
use Cwd;

my $cwd = getcwd();
my $dir = tempdir();
chdir $dir;

my $result;
sub paia(@) { ## no critic
    $result = test_app('App::PAIA' => [@_]);
}

paia 'session';
is $result->error, "no session file found.\n", "no session file";

paia 'config';
is $result->error, undef, "no error";
is $result->stdout, "{}\n", "empty configuration";

paia qw(config -c tmp.json --verbose);
is $result->error, "failed to open config file tmp.json\n", "failed to open config file";
is $result->output, '';

paia qw(config --ini);
is $result->stdout, "", "empty configuration (INI style)";

paia qw(config foo bar);
is $result->exit_code, 0, "set config value";

paia qw(config foo);
is $result->stdout, "bar\n", "get config value";

# TODO: create and test config file

chdir $cwd;

done_testing;
