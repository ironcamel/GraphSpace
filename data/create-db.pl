use strict;
use warnings;
use GraphSpace::Schema;

print "deploying db ...\n";
my $dsn = 'dbi:SQLite:dbname=graphspace.db';
my $schema = GraphSpace::Schema->connect($dsn);
$schema->deploy;
 
my @users = (
    { id => 'chrisp', password => 'chrisp', name => 'Chris Poirel' },
    { id => 'test', password => 'test', name => 'Test User' },
);

for my $user (@users) {
    $schema->resultset('User')->create($user);
}

print "done\n";
