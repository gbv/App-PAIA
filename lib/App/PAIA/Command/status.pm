#ABSTRACT: show current session status
package App::PAIA::Command::status;
use parent 'App::PAIA::Command';
use v5.14;
#VERSION

sub execute {
    my ($self, $opt, $args) = @_;

    say "config:   ".$self->app->global_options->config;
    say $self->json($self->config) if keys %{$self->config};    

    say "base URL: ".$self->base if defined $self->base;
    say "auth URL: ".$self->auth if defined $self->auth;
    say "core URL: ".$self->core if defined $self->core;
}

1;
