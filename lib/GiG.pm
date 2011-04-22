package GiG;
use Dancer ':syntax';

our $VERSION = '0.0001';

use Dancer::Plugin::Ajax;
use Dancer::Plugin::DBIC;
use File::Slurp qw(read_file);

get '/' => sub { redirect '/graphs' };

get '/admin' => sub { template 'admin' };

post '/admin' => sub {
    my $file = upload('graph_file');
    my $graph_id = params->{graph_name};
    my $content = $file->content;
    schema->resultset('Graph')->update_or_create({
        id      => $graph_id,
        graphml => $content,
    });
    redirect "/graphs/$graph_id";
};

get '/graphs' => sub {
    my $tag = params->{tag};
    my @graphs = $tag
        ? schema->resultset('GraphTag')->find({ name => $tag })->graphs
        : schema->resultset('Graph')->all;
    template graphs => {
        graphs => \@graphs,
        graph_tags => [ schema->resultset('GraphTag')->all ],
    };
};

ajax '/graphs/:graph_id.:format' => sub {
    my $graph = get_graph(params->{graph_id});
    return params->{format} eq 'json' ? $graph->json : $graph->graphml;
};

get '/graphs/:graph_id' => sub {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return "The graph [$graph_id] does not exist\n";
    };
    template graph => {
        graph_id => $graph_id,
        graph_format => $graph->json ? 'json' : 'graphml',
        graph_tags => [ $graph->tags ],
    };
};

post '/graphs/:graph_id/tags' => sub {
    my $tag_name = request->body;
    my $graph_id = params->{graph_id};
    debug "adding tag $tag_name to graph_id $graph_id";
    my $graph = get_graph($graph_id);
    my $tag =
        schema->resultset('GraphTag')->find_or_create({ name => $tag_name });
    $graph->add_to_tags($tag);
    return to_json { id => $tag->id, name => $tag_name };
};

del '/graphs/:graph_id/tags/:tag' => sub {
    my $tag_name = params->{tag};
    my $graph_id = params->{graph_id};
    debug "deleting tag $tag_name from graph_id $graph_id";
    my $graph = get_graph($graph_id);
    my $tag = schema->resultset('GraphTag')->find({ name => $tag_name });
    if ($tag) {
        $graph->remove_from_tags($tag);
        $tag->delete if $tag->graphs->count == 0;
    }
    return 1;
};

get '/foo' => sub { template 'foo' };

get '/api/graphs/:graph_id.:format' => sub {
    my $graph_id = params->{graph_id};
    my $format = params->{format};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return "No such graph exists with id $graph_id\n";
    }
    if ($format eq 'json') {
        content_type 'application/json';
        return $graph->json;
    } else {
        content_type 'text/xml';
        return $graph->graphml;
    }
};

put '/api/graphs/:graph_id.:format' => sub {
    my $graph_id = params->{graph_id};
    schema->resultset('Graph')->update_or_create({
        id               => $graph_id,
        params->{format} => request->body,
    });
    return "success: graph can be viewed at "
        . uri_for("/graphs/$graph_id") . "\n";
};

ajax '/ppi/:go_id' => sub {
    my $go_id = params->{go_id};
    debug "ajax ppi $go_id";
    return to_json get_ppi($go_id);
};

get '/ppi/:go_id' => sub {
    my $go_id = params->{go_id};
    debug "get ppi $go_id";

    if (not -f path config->{ppi_path}, $go_id) {
        status 404;
        return "The ppi graph [$go_id] does not exist\n";
    };
    template graph => {
        graph_id => $go_id,
        graph_format => 'json',
        is_ppi => 1,
    };
};

get '/tags' => sub {
    my @tags = schema->resultset('GraphTag')->all;
    return join ' ', map $_->name, @tags;
};

sub get_graph { schema->resultset('Graph')->find($_[0]) }

sub get_ppi {
    my ($go_id) = @_;
    my $path = path config->{ppi_path}, $go_id;
    debug "getting $path";
    my $ppi = from_json read_file $path;
    my $graph = {
        graph => {
            dataSchema => {
                nodes => [
                    { name => 'label', type => 'string' },
                    { name => 'popup', type => 'string' },
                    { name => 'tooltip', type => 'string' },
                    { name => 'color', type => 'string' },
                    { name => 'size', type => 'int' },
                    { name => 'shape', type => 'string' },
                    { name => 'go_function_id', type => 'string' },
                ],
                edges => [
                    { name => 'width', type => 'double' },
                    { name => 'label', type => 'string' },
                    { name => 'popup', type => 'string' },
                ],
            },
            data => {
                nodes => [
                    map {
                        id => $_,
                        label => $_,
                        size => 25,
                    }, @{$ppi->{nodes}}
                ],
                edges => [
                    map {
                        id => $_->[0] . '-' . $_->[1],
                        source => $_->[0],
                        target => $_->[1],
                        width => 3,
                    }, @{$ppi->{edges}}
                ],
            },
        },
    };
    return $graph;
}

true;
