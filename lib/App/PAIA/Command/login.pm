package App::PAIA::Command::login;
use strict;
use v5.10;
use parent 'App::PAIA::Command';

our $VERSION = '0.29';

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->login( $self->explicit_option('scope') );
}

1;

=head1 NAME

App::PAIA::Command::login - get a access token and patron identifier

=head1 DESCRIPTION

requests or renews an access_token from a PAIA auth server

=cut
