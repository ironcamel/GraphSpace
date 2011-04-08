package GiG;
use Dancer ':syntax';

our $VERSION = '0.0001';

use Dancer::Plugin::Ajax;
use Dancer::Plugin::DBIC;

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
    my @graph_ids;
    template graphs => {
        graphs => [ schema->resultset('Graph')->all ]
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
    };
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

sub get_graph { schema->resultset('Graph')->find($_[0]) }

true;
