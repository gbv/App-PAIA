#ABSTRACT: Utility class to read and write JSON files
package App::PAIA::File;
use strict;
use v5.10;
#VERSION

use App::PAIA::JSON;

our %DEFAULT = (
    'config'  => 'paia.json',
    'session' => 'paia-session.json'
);

sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;

    $self->{file} //= $DEFAULT{ $self->{type} }
        if -e $DEFAULT{ $self->{type} };

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
    $self->{data} = decode_json(<$fh>,$file);
    close $fh;
    
    $self->{logger}->("loaded $type file $file");
    
    $self->{data}; 
}

sub store {
    my ($self) = @_;
    my $type = $self->{type};
    my $file = $self->file // $DEFAULT{$type};

    open (my $fh, '>', $file) 
        or die "failed to open $type file $file\n";
    print {$fh} encode_json($self->{data});
    close $fh;

    $self->{logger}->("saved $type file $file");
}

1;

=head1 DESCRIPTION

This module implements an internal utility class to load and store config and
session files in JSON format.

=cut
