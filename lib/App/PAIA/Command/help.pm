#ABSTRACT: show help
package App::PAIA::Command::help;
use parent 'App::Cmd::Command::help';
use v5.14;
#VERSION

sub abstract {
    "show help (use 'man paia' or 'info paia' for detailed manual)";
}

sub execute {
    my ($self, $opts, $args) = @_;

    return App::Cmd::Command::help::execute(@_) if @$args;

    say $self->app->usage->leader_text . " [command options]";
    say;
    say "global options ('paia help <command>' shows command options):";
    say $self->app->usage->option_text;

    my @cmd_groups = (
        "PAIA auth commands" => [qw(login logout change)],
        "PAIA core commands" => [qw(patron items request renew cancel fees)],
        "client commands"    => [qw(status help commands)]
    );

    while (@cmd_groups) {
        say shift(@cmd_groups) . ":";
        for my $command (@{ shift @cmd_groups }) {
            my $abstract = $self->app->plugin_for($command)->abstract;
            printf "%9s: %s\n", $command, $abstract;
        }
        say;
    }    
}

1;
