#ABSTRACT: common base class of PAIA cli commands
package App::PAIA::Command;
use App::Cmd::Setup -command;
use v5.14;
#VERSION

use HTTP::Tiny 0.018; # core module 0.012 does not support verify_SSL
use JSON::PP qw();    # core module

# TODO: respect values .paia_session file

sub base { # get base URL
    my ($self) = @_;
    $self->app->global_options->base // $self->config->{base};
}

sub auth { # get auth URL
    my ($self) = @_;
    $self->app->global_options->auth // $self->config->{auth}
        // ( $self->base ? $self->base . '/auth' : undef );
}

sub core { # get core URL
    my ($self) = @_;
    $self->app->global_options->core // $self->config->{core}
        // ( $self->base ? $self->base . '/core' : undef );
}

# get current patron identifier
sub patron { $_[0]->{patron} }

# TODO: cleanup duplicated code
sub config_file {
    my ($self) = @_;
    $self->app->global_options->config
        // (-e 'paia.json' ? 'paia.json' : undef);
}
sub config {
    my ($self) = @_;
    $self->{config} //= do {
        my $file = $self->config_file;
        local (@ARGV, $/) = $file;
        defined $file ? $self->parse(<>,$file) : { };
    };
}
sub session_file {
    my ($self) = @_;
    $self->app->global_options->session
        // (-e '.paia_session' ? '.paia_session' : undef);
}
sub session {
    my ($self) = @_;
    $self->{session} //= do {
        my $file = $self->session_file;
        local (@ARGV, $/) = $file;
        defined $file ? $self->parse(<>,$file) : { };
    };
}

sub save_session {
    my ($self) = @_;
    my $file = $self->session_file // '.paia_session';
    say "saving session not implemented yet!";
}

sub agent {
    my ($self) = @_;
    $self->{agent} //= HTTP::Tiny->new(
        verify_SSL => (!$self->app->global_options->{insecure})
    );
}

sub request {
    my ($self, $method, $url, $param) = @_;
    $param //= { };

    my %options = (
        headers => {
            'Accept' => 'application/json',
        },
    );

    if ($url !~ /login$/) {
        my $token = $self->{access_token} // die "missing access_token - login required\n";
        $options{headers}->{Authorization} = "Bearer $token";
    }

    if ($method eq 'POST') {
        $options{headers}->{'Content-Type'} = 'application/json';
        $options{content} = $self->json($param);
    } elsif (%$param) {
        $url = URI->new($url)->query_form(%$param);
    }

    my $response = $self->agent->request( $method, $url, \%options );

    # TODO: more error checking

    if ($response->{status} ne '200') {
        die "HTTP request failed with response code ".$response->{status}.":\n".
            $response->{content}.
            "\n";
    }
    
    return $self->parse($response->{content});
}

sub parse {
    my $data = eval { JSON::PP->new->utf8->relaxed->decode($_[1]); };
    if ($@) {
        my $msg = reverse $@;
        $msg =~ s/.+? ta //sm;
        die sprintf "JSON error: %s in %s\n", scalar reverse($msg), $_[2];
    }
    return $data;
}

sub json {
    JSON::PP->new->utf8->pretty->encode($_[1]); 
}

sub login {
    my ($self, %params) = @_;

    my $auth = $self->auth // $self->usage_error("missing PAIA auth URL");

    $self->usage_error("missing username") unless defined $params{username};
    $self->usage_error("missing password") unless defined $params{password};
    if (defined $params{scopes}) {
        $params{scopes} =~ s/,/ /g;
    } else {
        delete $params{scopes} if exists $params{scopes};
    }
    $params{grant_type} = 'password';

    my $response = $self->request( "POST", "$auth/login", \%params );

    $self->{$_} = $response->{$_} for qw(expires_in access_token token_type patron scope);

    return $response;
}

sub token { $_[0]->{access_token} } 

1;
