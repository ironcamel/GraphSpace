package GraphSpace::Schema::Result::GraphToTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

GraphSpace::Schema::Result::GraphToTag

=cut

__PACKAGE__->table("graph_to_tag");

=head1 ACCESSORS

=head2 graph_id

  data_type: 'text'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "graph_id",
  {
    data_type      => "text",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "tag_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("graph_id", "tag_id");

=head1 RELATIONS

=head2 graph

Type: belongs_to

Related object: L<GraphSpace::Schema::Result::Graph>

=cut

__PACKAGE__->belongs_to(
  "graph",
  "GraphSpace::Schema::Result::Graph",
  { id => "graph_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tag

Type: belongs_to

Related object: L<GraphSpace::Schema::Result::GraphTag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "GraphSpace::Schema::Result::GraphTag",
  { id => "tag_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-20 09:46:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eJsRYsYi2UyqjZ5Nau4z8w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
