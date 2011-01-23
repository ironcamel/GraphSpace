#!/usr/local/bin/perl
use Dancer ':syntax';
use FindBin '$RealBin';
use Plack::Runner;

set apphandler => 'PSGI';
set environment => 'development';

my $psgi = path($RealBin, '..', 'bin', 'app.pl');
Plack::Runner->run($psgi);
