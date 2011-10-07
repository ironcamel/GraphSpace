#!/usr/bin/env perl
use 5.10.1;
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
    return $username eq $password and $username ~~ [qw(arjun chrisp test chrisl)];
}
