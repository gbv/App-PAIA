#ABSTRACT: common base class of PAIA client commands
package App::PAIA::Command;
use App::Cmd::Setup -command;
use v5.14;
#VERSION

use App::PAIA::Agent;
use App::PAIA::JSON;

# get option from command line, session, or config file
sub option { 
    my ($self, $name) = @_;
    $self->app->global_options->{$name} 
        // $self->session->{$name} 
        // $self->config->{$name};
}

# get base URL
sub base { $_[0]->option('base') }

# get auth URL
sub auth { 
    my ($self) = @_;
    $_[0]->option('auth') // ( $self->base ? $self->base . '/auth' : undef );
}

# get core URL
sub core {
    my ($self) = @_;
    $_[0]->option('core') // ( $self->base ? $self->base . '/core' : undef );
}

# get patron identifier
sub patron { $_[0]->option('patron') }

# get current scopes
sub scope { $_[0]->option('scope') }

# get verbose mode
sub verbose { $_[0]->option('verbose') }

sub token {
    my ($self) = @_;

    $self->app->global_options->{'token'}
        // $self->session->{'access_token'} 
        // $self->config->{'access_token'};
}

sub authentificated {
    my ($self, %options) = @_;

    # TODO: scope
    my $token = $self->token // return;
    my $expires = $self->session->{expires_at} // return;

    if ($expires <= time) {
        $self->log("access token expired.",$options{verbose});
        return;
    }

    if ($options{scope}) {
        my $scope = $self->scope // '';
        if ( index($scope, $options{scope}) == -1 ) {
            $self->log("curren scope '$scope' does not allow ".$options{scope},$options{verbose});
            return;
        }
    }

    return 1;
}

# emit a message only in verbose mode
sub log {
    my ($self, $msg, $verbose) = @_;
    if ($verbose // $self->verbose) {
        say "# $_" for split "\n", $msg;
    }
}

# <TODO>: cleanup duplicated code
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
        defined $file ? decode_json(<>,$file) : { };
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
        defined $file ? decode_json(<>,$file) : { };
    };
}
# </TODO>

sub save_session {
    my ($self) = @_;
    my $file = $self->session_file // '.paia_session';
    open (my $fh, '>', $file) or die "failed to open $file";
    print {$fh} encode_json($self->session);
    close $fh;
    $self->log("saved session to $file");
}

sub agent {
    my ($self) = @_;
    $self->{agent} //= App::PAIA::Agent->new(
        insecure => $self->option('insecure'),
        verbose  => $self->option('verbose')
    );
}

sub request {
    my ($self, $method, $url, $param) = @_;

    my %headers;
    if ($url !~ /login$/) {
        my $token = $self->token // die "missing access_token - login required\n";
        $headers{Authorization} = "Bearer $token";
    }

    my ($response, $json) = $self->agent->request( $method, $url, $param, %headers );

    if ($response->{status} ne '200') {
        die "HTTP request failed with response code ".$response->{status}.":\n".
            $response->{content}.
            "\n";
    }

    # TODO: more error handling

    if (my $scopes = $response->{headers}->{'x-oauth-scopes'}) {
        $self->{session}->{scope} = $scopes;
    }

    return $json;
}

sub login {
    my ($self, %params) = @_;

    my $auth = $self->auth // $self->usage_error("missing PAIA auth URL");

    $self->usage_error("missing username") unless defined $params{username};
    $self->usage_error("missing password") unless defined $params{password};
    if (defined $params{scope}) {
        $params{scope} =~ s/,/ /g;
    } else {
        delete $params{scope} if exists $params{scope};
    }
    $params{grant_type} = 'password';

    my $response = $self->request( "POST", "$auth/login", \%params );

    $self->{$_} = $response->{$_} for qw(expires_in access_token token_type patron scope);

    $self->{session}->{$_} = $response->{$_} for qw(access_token patron scope);
    $self->{session}->{expires_at} = time + $response->{expires_in};

    $self->save_session;

    return $response;
}

our %required_scopes = (
    patron  => 'read_patron',
    items   => 'read_item',
    request => 'write_item',
    renew   => 'write_item',
    cancel  => 'write_item',
    fees    => 'read_fees',
    change  => 'change_password',
);

sub core_request {
    my ($self, $method, $command, $params, $opt) = @_;

    my $core  = $self->core // $self->usage_error("missing PAIA core URL");
    my $scope = $required_scopes{$command};

    if (!$self->authentificated( scope => $scope )) {
        $self->log("auto-login with scope $scope");
        $self->login(
            username => ($self->app->global_options->{username} // $self->config->{username}),
            password => ($self->app->global_options->{password} // $self->config->{password}),
            scope    => $scope,
        );
    }

    my $patron = $self->patron // $self->usage_error("missing patron identifier");

    # TODO: URI-escape patron
    my $url = "$core/$patron";
    $url .= "/$command" if $command ne 'patron';

    $self->request( $method => $url );
}

1;
