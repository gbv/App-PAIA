# NAME

App::PAIA - Patrons Account Information API command line client

# STATUS

[![Build Status](https://travis-ci.org/gbv/App-PAIA.png)](https://travis-ci.org/gbv/App-PAIA)
[![Coverage Status](https://coveralls.io/repos/gbv/App-PAIA/badge.png?branch=master)](https://coveralls.io/r/gbv/App-PAIA?branch=master)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/App-PAIA.png)](http://cpants.cpanauthors.org/dist/App-PAIA)

# SYNOPSIS

    paia patron --base http://example.org/ --username alice --password 12345

Run `paia help` or `perldoc paia` for more commands and options.

# DESCRIPTION

The [Patrons Account Information API (PAIA)](http://gbv.github.io/paia/) is a
HTTP based API to access library patron information, such as loans,
reservations, and fees. This client can be used to access PAIA servers via
command line.

# USAGE

See the documentation of of [paia](https://metacpan.org/pod/paia) command.

To avoid SSL errors install [Mozilla::CA](https://metacpan.org/pod/Mozilla::CA) or use option `--insecure`.

# IMPLEMENTATION

The client is implemented using [App::Cmd](https://metacpan.org/pod/App::Cmd). There is a module for each command
in the App::PAIA::Command:: namespace and common functionality implemented in
[App::PAIA::Command](https://metacpan.org/pod/App::PAIA::Command).

# RESOURCES

- [http://gbv.github.io/paia/](http://gbv.github.io/paia/)

    PAIA specification

- [https://github.com/gbv/App-PAIA](https://github.com/gbv/App-PAIA)

    Code repository and issue tracker

# COPYRIGHT AND LICENSE

Copyright Jakob Voß, 2013-

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
