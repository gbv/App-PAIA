package App::PAIA;
use App::Cmd::Setup -app;
use v5.14;

sub global_opt_spec {
    ['base=s' => "base URL of PAIA server"],
    ['auth=s' => "base URL of PAIA auth server"],
    ['core=s' => "base URL of PAIA core server"],
    ['insecure|k' => "disable verification of SSL certificates"],
    ['config=s' => "configuration file (default is ./paia.json)", { default => 'paia.json' }],
    #['verbose|v' => "..."],
    ;
}

1;
