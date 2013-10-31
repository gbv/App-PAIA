#ABSTRACT: common base class of PAIA client commands
package App::PAIA::Command;
use strict;
use v5.10;
use App::Cmd::Setup -command;
#VERSION

use App::PAIA::Agent;
use App::PAIA::JSON;
use URI::Escape;
use URI;

sub config {
    my ($self) = @_;
    $self->{config} //= App::PAIA::JSON::File->new(
        owner => $self,
        type  => 'config',
        file  => $self->app->global_options->config,
    );
}

sub session {
    my ($self) = @_;
    $self->{session} //= App::PAIA::JSON::File->new(
        owner => $self,
        type  => 'session',
        file  => $self->app->global_options->session,
    );
}

sub option { 
    my ($self, $name) = @_;
    $self->app->global_options->{$name} # command line 
        // $self->session->get($name)   # session file
        // $self->config->get($name);   # config file
}

sub explicit_option {
    my ($self, $name) = @_;
    $self->app->global_options->{$name} # command line
        // $self->config->get($name);   # config file
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
        // $self->session->get('access_token') 
        // $self->config->get('access_token');
}

sub not_authentificated {
    my ($self, $scope) = @_;

    my $token = $self->token // return "missing access token";

    if ( my $expires = $self->session->get('expires_at') ) {
        if ($expires <= time) {
            return "access token expired";
        }
    }

    if ($scope and !$self->has_scope($scope)) {
        return "current scope does not include $scope";
    }

    return;
}

sub has_scope {
    my ($self, $scope) = @_;
    my $has_scope = $self->scope // '';
    return index($has_scope, $scope) != -1;
}

# emit a message only in verbose mode
sub log {
    my ($self, $msg, $verbose) = @_;
    if ($verbose // $self->verbose) {
        say "# $_" for split "\n", $msg;
    }
}

sub agent {
    my ($self) = @_;
    $self->{agent} //= App::PAIA::Agent->new(
        map { $_ => $self->option($_) } qw(insecure verbose quiet)
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
        my $msg = $response->{content} // 'HTTP request failed: '.$response->{status};
        die "$msg\n";
    }

    # TODO: more error handling

    if (my $scopes = $response->{headers}->{'x-oauth-scopes'}) {
        $self->session->set( scope => $scopes );
    }

    return $json;
}

sub login {
    my ($self, $scope) = @_;

    my $auth = $self->auth or $self->usage_error("missing PAIA auth server URL");

    # take credentials from command line or config file only
    my %params = (
        username => ($self->explicit_option('username') // $self->usage_error("missing username")),
        password => ($self->explicit_option('password') // $self->usage_error("missing password")),
        grant_type => 'password',
    );

    if (defined $scope) {
        $scope =~ s/,/ /g;
        $params{scope} = $scope;
    }

    my $response = $self->request( "POST", "$auth/login", \%params );

    $self->{$_} = $response->{$_} for qw(expires_in access_token token_type patron scope);

    $self->session->set( $_, $response->{$_} ) for qw(access_token patron scope);
    $self->session->set( expires_at => time + $response->{expires_in} );
    $self->session->set( auth => $auth );
    $self->session->set( core => $self->core ) if defined $self->core;

    $self->session->store;
    
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

sub auto_login_for {
    my ($self, $command) = @_;

    my $scope = $required_scopes{$command};

    if ($self->not_authentificated( $scope )) {
        # add to existing scopes (TODO: only if wanted)
        my $new_scope = join ' ', split(' ',$self->scope // ''), $scope;
        $self->log("auto-login with scope '$new_scope'");
        $self->login( $new_scope );
        if ( $self->scope and !$self->has_scope($scope) ) {
            die "current scope does not include $scope!\n";
        }
    }
}

sub core_request {
    my ($self, $method, $command, $params) = @_;

    my $core  = $self->core // $self->usage_error("missing PAIA core server URL");

    $self->auto_login_for($command);

    my $patron = $self->patron // $self->usage_error("missing patron identifier");

    my $url = "$core/".uri_escape($patron);
    $url .= "/$command" if $command ne 'patron';

    # save PAIA core URL in session
    if ( ($self->session->get('core') // '') ne $core ) {
        $self->session->set( core => $core );
        $self->session->store;
        # TODO: could we save new expiry as well? 
    }

    $self->request( $method => $url, $params );
}

# used in command::renew and ::cancel
sub uri_list {
    my $self = shift;
    map {
        /^((edition|item)=)?(.+)/;
        my $uri = URI->new($3);
        $self->usage_error("not an URI: $3") unless $uri and $uri->scheme;
        my $d = { ($2 // "item") => "$uri" };
        $d;
    } @_;
}

# TODO: Think about making this part of App::Cmd
sub execute {
    my $self = shift;

    if ($self->app->global_options->version) {
        $self->app->execute_command( $self->app->prepare_command('version') );
        exit;
    } elsif ($self->app->global_options->help) {
       $self->app->execute_command( $self->app->prepare_command('help', @ARGV) );
        exit;
    }

    my $response = $self->_execute(@_);
    print encode_json($response) if defined $response;
}

1;
