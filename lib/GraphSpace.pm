package GraphSpace;
use Dancer ':syntax';

our $VERSION = '0.0001';

use Dancer::Plugin::Ajax;
use Dancer::Plugin::DBIC;
use File::Slurp qw(read_file);

# Automagically create db tables the first time this app is run
eval { schema->resultset('User')->count };
schema->deploy if $@;

hook before => sub {
    var api_user => request->env->{REMOTE_USER};
    #debug '*** referer: '. request->header('referer');

    if (! session('user') && request->path_info !~ m{^/(login|help|api)}) {
        var requested_path => request->path_info;
        #request->path_info('/login');
    }
};

hook before_template_render => sub {
    my $tokens = shift;
    $tokens->{user_id} = session 'user';
};

get '/' => sub { redirect uri_for '/graphs' };

get '/help' => sub { template help => { active_nav => 'help' } };

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
        redirect uri_for(params->{requested_path} || '/graphs');
    } else {
        redirect uri_for('/login') . '?failed=1';
    }
};

get '/logout' => sub {
    session->destroy;
    redirect uri_for '/graphs';
};

get '/boot' => sub {
    template graphs => {
        graphs => [map {name => $_, id => int(rand() * 999)}, qw(foo bar poo)],
        graph_tags => [map {name => $_}, (qw(foo bar poo)) x 4],
    };
};

get '/graphs' => sub {
    my $tag = params->{tag};
    my $user_id = session 'user';
    my $search = $user_id ? { user_id => $user_id } : {};
    my @graphs = $tag
        ? schema->resultset('GraphTag')->find({ name => $tag })->graphs
            ->search($search, { rows => 100 })
        : schema->resultset('Graph')->search($search, { rows => 100 });
    my @tags = schema->resultset('GraphTag')->search({}, { rows => 100 });
    template graphs => {
        user_id    => $user_id,
        graphs     => \@graphs,
        graph_tags => \@tags,
    };
};

ajax '/graphs/:graph_id' => sub {
    my $graph = get_graph(params->{graph_id});
    return $graph ? $graph->json : { error => 'graph not found' };
};

get '/graphs/:graph_id' => sub {
    my $graph_id = param 'graph_id';
    my $size = param('size') || '';
    my $template = $size eq 'large' ? 'large' : 'graph';
    my $graph = get_graph($graph_id);
    return send_error "The graph [$graph_id] does not exist", 404
        unless $graph;
    template $template => {
        graph        => $graph,
        graph_tags   => [ $graph->tags ],
    };
};

get '/tags' => sub {
    my @tags = map { $_->name } schema->resultset('GraphTag')->all;
    return to_json \@tags;
};

post '/graphs/:graph_id/tags' => sub {
    my $tag_name = request->body;
    my $graph_id = params->{graph_id};
    add_tags($graph_id, [ $tag_name ]);
    return { name => $tag_name };
};

del '/graphs/:graph_id/tags/:tag' => sub {
    my $tag_name = params->{tag};
    my $graph_id = params->{graph_id};
    delete_tags($graph_id, [$tag_name]);
    return 1;
};

get '/foo' => sub { template 'foo' => {}, {layout => 0}};

get '/api/graphs/:graph_id' => sub {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return "No such graph exists with id $graph_id\n";
    }
    content_type 'application/json';
    return $graph->json;
};

post '/api/graphs' => sub {
    my $json = request->body;
    my $data = from_json $json;
    my $name = $data->{metadata}{name}
        or return send_error("The graph metadata must contain a name\n", 400);
    my $graph = schema->resultset('Graph')->create({
        name    => $name,
        json    => $json,
        user_id => var('api_user'),
    });
    my $graph_id = $graph->id;
    my $tags = $data->{metadata}{tags};
    add_tags($graph_id, $tags) if $tags;
    status 201;
    header location => uri_for("/api/graphs/$graph_id");
    return {
        id  => $graph_id,
        url => uri_for("/graphs/$graph_id")->as_string,
    };
};

put '/api/graphs/:graph_id' => sub {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return { error => "No graph exists with an id of $graph_id" };
    }
    my $json = request->body;
    my $data = from_json $json;
    my $name = $data->{metadata}{name};
    if (not defined $name) {
        status 400;
        return { error => "The graph metadata must contain a name" };
    }
    $graph->update({
        name    => $name,
        json    => $json,
        user_id => var('api_user'),
    });
    delete_all_tags($graph_id);
    my $tags = $data->{metadata}{tags};
    add_tags($graph_id, $tags) if $tags;
    return {
        id  => $graph_id,
        url => uri_for("/graphs/$graph_id")->as_string,
    };
};

del '/graphs/:graph_id' => \&delete_graph;

del '/api/graphs/:graph_id' => \&delete_graph;

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
        is_ppi => 1,
    };
};

sub get_graph { schema->resultset('Graph')->find($_[0]) }

sub delete_graph {
    my $graph_id = params->{graph_id};
    my $graph = get_graph($graph_id);
    if (not $graph) {
        status 404;
        return { error => "No graph exists with an id of $graph_id" };
    }
    my $user_id = session('user') // var('api_user') // '';
    if ($graph->user_id ne $user_id) {
        status 403;
        return { error => "You can only delete your own graphs" };
    }

    $graph->delete;
    # TODO: Should we delete orphaned tags? DBIC takes care of deleting rows
    # from relationship table.
    return { id => $graph_id };
};

sub validate_tags {
    my ($tags) = @_;
}

sub add_tags {
    my ($graph_id, $tags) = @_;
    my $graph = get_graph($graph_id);
    for my $tag_name (@$tags) {
        #debug "adding tag $tag_name to graph_id $graph_id";
        $tag_name =~ s/\s/-/g; # We are not allowing whitespace in tags.
        $tag_name = lc $tag_name;
        my $tag = schema->resultset('GraphTag')
            ->find_or_create({ name => $tag_name });
        $graph->add_to_tags($tag);
    }
}

sub delete_tags {
    my ($graph_id, $tags) = @_;
    my $graph = get_graph($graph_id);
    for my $tag_name (@$tags) {
        #debug "deleting tag $tag_name from graph_id $graph_id";
        my $tag = schema->resultset('GraphTag')->find({ name => $tag_name });
        if ($tag) {
            $graph->remove_from_tags($tag);
            $tag->delete if $tag->graphs->count == 0;
        }
    }
}

sub delete_all_tags {
    my ($graph_id) = @_;
    debug "deleting all tags for graph_id $graph_id";
    my $graph = get_graph($graph_id);
    for my $tag ($graph->tags) {
        debug "deleting tag " . $tag->name . " from graph_id $graph_id";
        $graph->remove_from_tags($tag);
        $tag->delete if $tag->graphs->count == 0;
    }
}

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
