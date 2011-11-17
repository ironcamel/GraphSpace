package GraphSpace::Schema::Result::Graph;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->load_components(qw(InflateColumn::DateTime TimeStamp));

__PACKAGE__->table('graph');

__PACKAGE__->add_columns(
    id       => { data_type => 'varchar(500)', is_nullable => 0 },
    user_id  => { data_type => 'varchar(100)', is_nullable => 0 },
    json     => { data_type => 'text', is_nullable => 0 },
    created  => {
        data_type     => 'timestamp',
        is_nullable   => 0,
        set_on_create => 1,
    },
    modified => {
        data_type     => 'timestamp',
        is_nullable   => 0,
        set_on_create => 1,
        set_on_update => 1,
    },
);

__PACKAGE__->set_primary_key('id', 'user_id');

__PACKAGE__->belongs_to(
    user => "GraphSpace::Schema::Result::User",
    { 'foreign.id' => 'self.user_id' },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->has_many(
    graph_to_tag => 'GraphSpace::Schema::Result::GraphToTag',
    {
        'foreign.graph_id' => 'self.id',
        'foreign.user_id'  => 'self.user_id',
    },
    {
        cascade_copy   => 0,
        cascade_delete => 1,
    },
);

__PACKAGE__->many_to_many(qw(tags graph_to_tag tag));

1;
