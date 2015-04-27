package App::PAIA::Command::patron;
use strict;
use v5.10;
use parent 'App::PAIA::Command';

sub _execute {
    my ($self, $opt, $args) = @_;

    $self->core_request( 'GET', 'patron' );
}

1;
__END__

=head1 NAME

App::PAIA::Command::patron - get general patron information

=cut
