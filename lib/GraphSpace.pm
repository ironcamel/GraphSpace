package GraphSpace;
use Dancer ':syntax';

our $VERSION = '0.0001';

use Dancer::Plugin::Ajax;
use Dancer::Plugin::DBIC;
use File::Slurp qw(read_file);

before sub {
    var api_user => request->env->{REMOTE_USER};
    #debug '*** referer: '. request->header('referer');

    if (! session('user') && request->path_info !~ m{^/(login|help|api)}) {
        var requested_path => request->path_info;
        request->path_info('/login');
    }
};

before_template sub {
    my $tokens = shift;
    $tokens->{user_id} = session 'user';
};

get '/' => sub { redirect uri_for '/graphs' };

get '/admin' => sub { template 'admin' };

post '/admin' => sub {
    my $file = upload('graph_file');
    my $graph_id = params->{graph_name};
    my $content = $file->content;
    schema->resultset('Graph')->update_or_create({
        id   => $graph_id,
        json => $content,
    });
    redirect "/graphs/$graph_id";
};

get '/login' => sub {
    template login => {
        failed         => params->{failed},
        requested_path => vars->{requested_path},
    };
};

post '/login' => sub {
    my $username = params->{username};
    my $password = params->{password};
    my $user = schema->resultset('User')->find($username);
    if ($user and $user->password eq $password) {
        session user => $username;
        redirect uri_for params->{requested_path};
    } else {
        redirect uri_for('/login') . '?failed=1';
    }
};

get '/logout' => sub {
    session->destroy;
    redirect uri_for '/login';
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
        graph        => $graph,
        graph_format => $graph->json ? 'json' : 'graphml',
        graph_tags   => [ $graph->tags ],
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

get '/foo' => sub { template 'foo' => {}, {layout => 0}};

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

post '/api/graphs' => sub {
    my $json = request->body;
    my $data = from_json $json;
    my $name = $data->{metadata}{name};
    if (not $name) {
        status 400;
        return "The graph metadata must contain a name\n";
    }
    $data->{graph}{dataSchema} = {
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
    };
    my $graph = schema->resultset('Graph')->create({
        name    => $name,
        json    => to_json($data),
        user_id => var('api_user'),
    });
    return "success: graph can be viewed at "
        . uri_for("/graphs/" . $graph->id) . "\n";
};

put '/api/graphs/:graph_id.:format' => sub {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return "No graph exists with an id of $graph_id\n";
    }
    $graph->update({ json => request->body });
    return "Graph $graph_id was updated\n";
};

del '/api/graphs/:graph_id' => sub {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return "No graph exists with an id of $graph_id\n";
    }
    $graph->delete;
    # TODO: Should we delete orphaned tags? DBIC takes care of deleting rows
    # from relationship table.
    return "Deleted graph $graph_id\n";
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
    my @tags = map { $_->name } schema->resultset('GraphTag')->all;
    return to_json \@tags;
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
                        popup => "<a target='_blank' href='http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=$_'>$_</a>",
                        tooltip => $_,
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
