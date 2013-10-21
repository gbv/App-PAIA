#ABSTRACT: Patrons Account Information API command line client 
package App::PAIA;
use base 'App::Cmd';
use v5.14;
#VERSION

sub global_opt_spec {
    ['base|b=s' => "base URL of PAIA server"],
    ['auth=s' => "base URL of PAIA auth server"],
    ['core=s' => "base URL of PAIA core server"],
    ['insecure|k' => "disable verification of SSL certificates"],
    ['config|c=s' => "configuration file (default is ./paia.json)"],
    ['session|s=s' => "session file (default is ./.paia_session)"],
    ['verbose|v' => "show what's going on internally"],
    ['token|t=s' => "explicit access_token"];
}

1;
