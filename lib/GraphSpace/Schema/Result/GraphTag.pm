package GraphSpace::Schema::Result::GraphTag;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table("graph_tag");

__PACKAGE__->add_columns(
  id => { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  name => { data_type => "text", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
    graph_to_tag => "GraphSpace::Schema::Result::GraphToTag",
    { "foreign.tag_id" => "self.id" },
    { cascade_copy => 0, cascade_delete => 1 },
);

__PACKAGE__->many_to_many(qw(graphs graph_to_tag graph));

1;
