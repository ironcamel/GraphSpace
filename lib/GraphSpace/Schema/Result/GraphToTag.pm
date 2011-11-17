package GraphSpace::Schema::Result::GraphToTag;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table("graph_to_tag");

__PACKAGE__->add_columns(
    graph_id => {
        data_type      => 'varchar(500)',
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    user_id => {
        data_type      => 'varchar(100)',
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    tag_id => {
        data_type      => 'integer',
        is_foreign_key => 1,
        is_nullable    => 0,
    },
);

__PACKAGE__->set_primary_key("graph_id", "tag_id");

__PACKAGE__->belongs_to(
    graph => "GraphSpace::Schema::Result::Graph",
    {
        'foreign.id'      => 'self.graph_id',
        'foreign.user_id' => 'self.user_id',
    },
    {
        is_deferrable => 1,
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
  tag => "GraphSpace::Schema::Result::GraphTag",
  { id => "tag_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
