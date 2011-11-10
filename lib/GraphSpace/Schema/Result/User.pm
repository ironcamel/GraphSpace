package GraphSpace::Schema::Result::User;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('user');

__PACKAGE__->add_columns(
    id       => { data_type => 'varchar(100)', is_nullable => 0 },
    password => { data_type => 'varchar(100)', is_nullable => 0 },
    name     => { data_type => 'varchar(100)', is_nullable => 1 },
    email    => { data_type => 'varchar(100)', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
    graphs => 'GraphSpace::Schema::Result::Graph',
    { 'foreign.user_id' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 1 },
);

1;
