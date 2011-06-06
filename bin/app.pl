#!/usr/bin/env perl
use Dancer;
use Plack::Builder;
use GraphSpace;

builder {
    enable_if { shift->{PATH_INFO} =~ qr(^/api) } 'Auth::Basic',
        authenticator => \&authen_cb;
    #enable "Auth::Digest", realm => "Secured", secret => "blahblahblah",
    #    authenticator => sub {
    #    my ($username, $env) = @_;
    #    return $password; # for $username
    #};
    dance;
};

sub authen_cb {
    my($username, $password) = @_;
    return $username eq 'arjun' || $username eq 'test';
}
