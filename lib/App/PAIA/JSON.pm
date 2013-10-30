#ABSTRACT: Utility functions to encode/decode JSON
package App::PAIA::JSON;
use strict;
use v5.10;
#VERSION

use parent 'Exporter';
our @EXPORT = qw(decode_json encode_json);
use JSON::PP qw();    # core module

sub decode_json {
    my $json = shift;
    my $data = eval { JSON::PP->new->utf8->relaxed->decode($json); };
    if ($@) {
        my $msg = reverse $@;
        $msg =~ s/.+? ta //sm;
        $msg = "JSON error: " . scalar reverse($msg);
        $msg .= " in " . shift if @_;
        die "$msg\n";
    }
    return $data;
}

sub encode_json {
    JSON::PP->new->utf8->pretty->encode($_[0]); 
}

{
    # Internal Utility class to read and write JSON files
    package App::PAIA::JSON::File;
    use strict;
    use v5.10;

    our %DEFAULT = (
        'config'  => 'paia.json',
        'session' => 'paia-session.json'
    );

    sub new {
        my $class = shift;
        my $self = bless { @_ }, $class;

        $self->{file} //= $DEFAULT{ $self->{type} } if -e $DEFAULT{ $self->{type} };

        $self;
    }

    sub file {
        $_[0]->{file};
    }

    sub get {
        my ($self, $key) = @_;
        $self->{data} //= $self->load;
        $self->{data}->{$key};
    }

    sub delete {
        my ($self, $key) = @_;
        $self->{data} //= $self->load;
        delete $self->{data}->{$key};
    }

    sub set {
        my ($self, $key, $value) = @_;
        $self->{data} //= { };
        $self->{data}->{$key} = $value;
    }

    sub load {
        my ($self) = @_;

        my $type = $self->{type};
        my $file = $self->file // return($self->{data} = { });
        
        local $/;
        open (my $fh, '<', $file) 
            or die "failed to open $type file $file\n";
        $self->{data} = App::PAIA::JSON::decode_json(<$fh>,$file);
        close $fh;
        
        # this may trigger a recursion
        $self->{owner}->log("loaded $type file $file");
        
        $self->{data}; 
    }

    sub store {
        my ($self) = @_;
        my $type = $self->{type};
        my $file = $self->file // $DEFAULT{$type};

        open (my $fh, '>', $file) 
            or die "failed to open $type file $file\n";
        print {$fh} App::PAIA::JSON::encode_json($self->{data});
        close $fh;

        $self->{owner}->log("saved $type file $file");
    }

}

1;

=head1 DESCRIPTION

This module wraps and exports method C<encode_json> and C<decode_json> from
L<JSON::PP>. On encoding JSON is pretty-printed. Decoding is relaxed and
with better error message on failure. The module further includes an internal
utility class to load and store JSON files.

=cut
