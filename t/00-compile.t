use strict;
use warnings;
use Test::More;
 
like(qx{$^X -c script/paia 2>&1}, qr{paia syntax OK}ms, q{compiles});

done_testing;
