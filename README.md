This repository contains an experimental command line client for the 
**[Patrons Account Information API (PAIA)](http://gbv.github.io/paia)**.

The client is implemented in Perl and requires at least version 5.14.

The current version is available in a git repository at
<https://github.com/gbv/App-PAIA>. Bug reports and feature requests can be
raised at <https://github.com/gbv/App-PAIA/issues>.

## Installation

## From CPAN

Use your favorite CPAN installer to install the CPAN module
[App::PAIA](https://metacpan.org/release/App-PAIA).

With cpanminus ([installation described
here](https://metacpan.org/pod/App::cpanminus#INSTALLATION) the
client can be installed on command line with

    cpanm App::PAIA 

or

    sudo cpanm App::PAIA

### Prebuild packages

Software packages for Debian and other Linux systems are not available yet.

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

[![Build Status](https://travis-ci.org/gbv/App-PAIA.png)](https://travis-ci.org/gbv/App-PAIA)
