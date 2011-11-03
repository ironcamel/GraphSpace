#!/usr/bin/env perl
use 5.10.1;
use Dancer;
use Plack::Builder;
use GraphSpace;
use Dancer::Plugin::DBIC qw(schema);
#use Dancer::Plugin::NYTProf;

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
    my ($user, $pass) = @_;
    return schema->resultset('User')->count({ id => $user, password => $pass });
}
