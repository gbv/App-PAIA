#ABSTRACT: show or modify configuration
package App::PAIA::Command::config;
use strict;
use v5.10;
use parent 'App::PAIA::Command';
#VERSION

use App::PAIA::JSON;

sub description {
<<MSG
This command shows or modifies the current configuration. Configuration
is printed as JSON object or in INI-sytle as sorted key-value-pairs.
MSG
}

sub usage_desc {
    "%c config %o [ key [value] ]"
}

sub opt_spec {
    ['ini|i' => 'print config values in INI-style as sorted key-value-pairs'],
    ['delete|d=s' => 'remove a key from the configuration file'];
}

sub _execute {
    my ($self, $opt, $args) = @_;

    if (defined $opt->delete) {
        $self->config->load;
        $self->config->delete($opt->delete);
        $self->config->store;
        exit;
    }

    if (@$args) {
        my ($key, $value) = @$args;

        if (defined $value) {
            $self->config->set( $key => $value );
            $self->config->store;
            exit;
        } elsif( defined ($value = $self->config->get($key)) ) {
            say $value;
            exit;
        } else {
            exit 1;
        }
    }
        
    $self->config->load;

    if ($opt->ini) {
        foreach ( sort keys %{$self->config->{data}} ) {
            print "$_=".$self->config->get($_)."\n" 
        }
    } else {
        print encode_json($self->config->{data});
    }
     
    return;
}

1;
