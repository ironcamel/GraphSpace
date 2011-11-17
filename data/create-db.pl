use strict;
use warnings;
use GraphSpace::Schema;

print "deploying db ...\n";
my $dsn = 'dbi:SQLite:dbname=graphspace.db';
my $schema = GraphSpace::Schema->connect($dsn);
$schema->deploy;
 
print "done\n";
