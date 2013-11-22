#ABSTRACT: common base class of PAIA client commands
package App::PAIA::Command;
use strict;
use v5.10;
use App::Cmd::Setup -command;
#VERSION

use App::PAIA::Agent;
use App::PAIA::JSON;
use App::PAIA::File;
use URI::Escape;
use URI;

# Implements lazy accessors just like Mo, Moo, Moose...
sub has {
    my ($name, %options) = @_;
    my $default = $options{default};
    no strict 'refs'; ## no critic 
    *{__PACKAGE__."::$name"} = sub {
        @_ > 1 
            ? $_[0]->{$name} = $_[1]
            : (!exists $_[0]->{$name} && $default)
                ? $_[0]->{$name} = $default->($_[0])
                : $_[0]->{$name}
    }
}

has config => ( 
    default => sub {
        App::PAIA::File->new(
            logger => $_[0]->logger,
            type   => 'config',
            file   => $_[0]->app->global_options->config,
        ) 
    }
);

has session => ( 
    default => sub { 
        App::PAIA::File->new(
            logger => $_[0]->logger,
            type   => 'session',
            file   => $_[0]->app->global_options->session,
        ) 
    }
);

has agent => (
    default => sub {
        App::PAIA::Agent->new(
            insecure => $_[0]->option('insecure'),
            logger   => $_[0]->logger,
            dumper   => $_[0]->dumper,
        );
    }
);

has logger => (
    default => sub {
        ($_[0]->app->global_options->verbose || $_[0]->app->global_options->debug)
            ? sub { say "# $_" for split "\n", $_[0]; }
            : sub { };
    }
);

has dumper => (
    default => sub {
        $_[0]->app->global_options->debug
            ? sub { say "> $_" for split "\n", $_[0]; }
            : sub { };
    }
);

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

#has_option 'base';
#has_option 'patron';

# get base URL
sub base { $_[0]->option('base') }

# get patron identifier
sub patron { 
    $_[0]->option('patron')
}

# get current scopes
sub scope { $_[0]->option('scope') }

sub username {
    $_[0]->explicit_option('username') // $_[0]->usage_error("missing username");
}

sub password {
    $_[0]->explicit_option('password') // $_[0]->usage_error("missing password");
}

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

    if ($scope and $self->scope and !$self->has_scope($scope)) {
        return "current scope '{$self->scope}' does not include $scope!\n";
    }

    return;
}

sub has_scope {
    my ($self, $scope) = @_;
    my $has_scope = $self->scope // '';
    return index($has_scope, $scope) != -1;
}

sub request {
    my ($self, $method, $url, $param) = @_;

    my %headers;
    if ($url !~ /login$/) {
        my $token = $self->token // die "missing access_token - login required\n";
        $headers{Authorization} = "Bearer $token";
    }

    my ($response, $json) = $self->agent->request( $method, $url, $param, %headers );

    # handle request errors
    if (ref $json and defined $json->{error}) {
        my $msg = $json->{error};
        if (defined $json->{error_description}) {
            $msg .= ': '.$json->{error_description};
        }
        die "$msg\n";
    }

    if ($response->{status} ne '200') {
        my $msg = $response->{content} // 'HTTP request failed: '.$response->{status};
        die "$msg\n";
    }

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
        username   => $self->username,
        password   => $self->password,
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
    items   => 'read_items',
    request => 'write_items',
    renew   => 'write_items',
    cancel  => 'write_items',
    fees    => 'read_fees',
    change  => 'change_password',
);

sub auto_login_for {
    my ($self, $command) = @_;

    my $scope = $required_scopes{$command};

    if ( $self->not_authentificated($scope) ) {
        # add to existing scopes (TODO: only if wanted)
        my $new_scope = join ' ', split(' ',$self->scope // ''), $scope;
        $self->logger->("auto-login with scope '$new_scope'");
        $self->login( $new_scope );
        if ( $self->scope and !$self->has_scope($scope) ) {
            die "current scope '{$self->scope}' does not include $scope!\n";
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

    my $json = $self->request( $method => $url, $params );

    if ($json->{doc}) {
        # TODO: more details about failed documents
        my @errors = grep { defined $_ } map { $_->{error} } @{$json->{doc}};
        if (@errors) {
            die join("\n", @errors)."\n";;
        }
    }

    return $json;
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
    if (defined $response and !$self->app->global_options->quiet) {
        print encode_json($response);
    }
}

1;
