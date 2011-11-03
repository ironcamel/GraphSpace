package GraphSpace::Schema::Result::Graph;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('graph');

__PACKAGE__->add_columns(
    id      => { data_type => 'integer', is_auto_increment => 1,
                 is_nullable => 0 },
    name    => { data_type => 'text', is_nullable => 1 },
    json    => { data_type => 'text', is_nullable => 1 },
    user_id => { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
    user => "GraphSpace::Schema::Result::User",
    { id => "user_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->has_many(
    graph_to_tag => 'GraphSpace::Schema::Result::GraphToTag',
    { 'foreign.graph_id' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 1 },
);

__PACKAGE__->many_to_many(qw(tags graph_to_tag tag));

1;
