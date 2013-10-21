#ABSTRACT: Patrons Account Information API command line client 
package App::PAIA;
use base 'App::Cmd';
use v5.14;
#VERSION

sub global_opt_spec {
    ['base=s' => "base URL of PAIA server"],
    ['auth=s' => "base URL of PAIA auth server"],
    ['core=s' => "base URL of PAIA core server"],
    ['insecure|k' => "disable verification of SSL certificates"],
    ['config=s' => "configuration file (default is ./paia.json)", { default => 'paia.json' }],
    ['verbose|v' => "show what's going on internally"];
}

1;
