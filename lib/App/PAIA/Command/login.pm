package App::PAIA::Command::login;
use strict;
use v5.10;
use parent 'App::PAIA::Command';

sub description {
    "requests or renews an access_token from a PAIA auth server."
}

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->login( $self->explicit_option('scope') );
}

1;
__END__

=head1 NAME

App::PAIA::Command::login - get a access token and patron identifier

=cut
