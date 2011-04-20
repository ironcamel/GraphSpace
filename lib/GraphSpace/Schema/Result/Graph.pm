package GraphSpace::Schema::Result::Graph;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GraphSpace::Schema::Result::Graph

=cut

__PACKAGE__->table("graph");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 json

  data_type: 'text'
  is_nullable: 1

=head2 graphml

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "json",
  { data_type => "text", is_nullable => 1 },
  "graphml",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 graphs_to_tag

Type: has_many

Related object: L<GraphSpace::Schema::Result::GraphToTag>

=cut

__PACKAGE__->has_many(
  "graphs_to_tag",
  "GraphSpace::Schema::Result::GraphToTag",
  { "foreign.graph_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-20 09:46:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:60HGfIWOw9AqMK1KJP9ljg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
