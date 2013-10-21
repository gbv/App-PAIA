This repository contains an experimental command line client for the 
**[Patrons Account Information API (PAIA)](http://gbv.github.io/paia)**.

The client is implemented in Perl and requires at least version 5.14.

The current version is available in a git repository at
<https://github.com/gbv/App-PAIA>. Bug reports and feature requests can be
raised at <https://github.com/gbv/App-PAIA/issues>.

## Installation

Unless released at CPAN and as package for your favorite operating system,
one needs to build and install the client from scratch after cloning/copying
from the repository .

### Build and install from scratch

The client is automatically tested on [Travis CI](https://travis-ci.org), so
the following should always work on a fresh system with Perl >= 5.14 and
[cpanminus](http://search.cpan.org/perldoc?App::cpanminus):

    cpanm --quiet --notest --skip-satisfied Dist::Zilla Pod::Weaver::Plugin::Encoding
    dzil authordeps | grep -vP '[^\w:]' | xargs -n 5 -P 10 cpanm --quiet --notest --skip-satisfied
    dzil listdeps | grep -vP '[^\w:]' | cpanm --notest
    dzil install

This way, however, the manual is not installed, so `man paia` won't work.

## Code status

[![Build Status](https://travis-ci.org/nichtich/App-PAIA.png)](https://travis-ci.org/nichtich/App-PAIA)
[![Coverage Status](https://coveralls.io/repos/nichtich/App-PAIA/badge.png?branch=master)](https://coveralls.io/r/nichtich/App-PAIA?branch=master)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/App-PAIA.png)](http://cpants.cpanauthors.org/dist/App-PAIA)
