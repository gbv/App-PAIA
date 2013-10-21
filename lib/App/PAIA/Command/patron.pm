#ABSTRACT: get general patron information
package App::PAIA::Command::patron;
use base 'App::PAIA::Command';
use v5.14;
#VERSION

sub opt_spec {
    ["username:s"=>"username or -number for login"],
    ["password:s"=>"password for login"],
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $core = $self->core // $self->usage_error("missing PAIA core URL");

    if (!$self->token) {
        $self->login(
            username => ($opt->username // $self->config->{username}),
            password => ($opt->password // $self->config->{password}),
            scopes   => 'read_patron'
        );
    }

    # TODO:
    # TODO: die if not logged in
    
    my $patron = $self->patron; # TODO: URI-escape
    my $data = $self->request( "GET", "$core/$patron" );

    say $self->json($data);
}

1;
