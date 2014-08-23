use strict;
use warnings;
use utf8;
use File::Basename 'dirname';
use File::Spec::Functions qw{catdir splitdir rel2abs canonpath};
use lib catdir(dirname(__FILE__), '../lib');
use lib catdir(dirname(__FILE__), 'lib');
use Test::More;
use Mojo::DOM;
use Mojo::Crawler;
use Mojo::Crawler::Queue;
use Mojo::Transaction::HTTP;
use Test::More tests => 19;

{
    my $html = <<EOF;
<html>
<head>
    <link rel="stylesheet" type="text/css" href="css1.css" />
    <link rel="stylesheet" type="text/css" href="css2.css" />
    <script type="text/javascript" src="js1.js"></script>
    <script type="text/javascript" src="js2.js"></script>
</head>
<body>
<a href="index1.html">A</a>
<a href="index2.html">B</a>
<a href="mailto:a\@example.com">C</a>
<a href="tel:0000">D</a>
<map name="m_map" id="m_map">
    <area href="index3.html" coords="" title="E" />
</map>
</body>
</html>
EOF
    
    my $tx = Mojo::Transaction::HTTP->new;
    $tx->req->url(Mojo::URL->new('http://example.com/'));
    $tx->res->code(200);
    $tx->res->body($html);
    $tx->res->headers->content_type('text/html');
    
    my $bot = Mojo::Crawler->new;
    $bot->discover($tx, Mojo::Crawler::Queue->new);
    my @array = @{$bot->{queues}};
    
    my $queue;
    $queue = shift @array;
    is $queue->literal_uri, 'css1.css', 'right url';
    is $queue->resolved_uri, 'http://example.com/css1.css', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'css2.css', 'right url';
    is $queue->resolved_uri, 'http://example.com/css2.css', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'js1.js', 'right url';
    is $queue->resolved_uri, 'http://example.com/js1.js', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'js2.js', 'right url';
    is $queue->resolved_uri, 'http://example.com/js2.js', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'index1.html', 'right url';
    is $queue->resolved_uri, 'http://example.com/index1.html', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'index2.html', 'right url';
    is $queue->resolved_uri, 'http://example.com/index2.html', 'right url';
    $queue = shift @array;
    is $queue->literal_uri, 'index3.html', 'right url';
    is $queue->resolved_uri, 'http://example.com/index3.html', 'right url';
    $queue = shift @array;
    is $queue, undef, 'no more urls';
}
{
    my $html = <<EOF;
<html>
<head>
    <base href="http://example2.com/">
    <link rel="stylesheet" type="text/css" href="css1.css" />
</head>
<body>
</body>
</html>
EOF
    
    my $tx = Mojo::Transaction::HTTP->new;
    $tx->req->url(Mojo::URL->new('http://example.com/'));
    $tx->res->code(200);
    $tx->res->body($html);
    $tx->res->headers->content_type('text/html');
    
    my $bot = Mojo::Crawler->new;
    $bot->discover($tx, Mojo::Crawler::Queue->new);
    my @array = @{$bot->{queues}};
    
    my $queue;
    $queue = shift @array;
    is $queue->literal_uri, 'css1.css', 'right url';
    is $queue->resolved_uri, 'http://example2.com/css1.css', 'right url';
}
{
    my $html = <<EOF;
<html>
<head>
    <base href="/">
    <link rel="stylesheet" type="text/css" href="css1.css" />
</head>
<body>
</body>
</html>
EOF
    
    my $tx = Mojo::Transaction::HTTP->new;
    $tx->req->url(Mojo::URL->new('http://example.com/'));
    $tx->res->code(200);
    $tx->res->body($html);
    $tx->res->headers->content_type('text/html');
    
    my $bot = Mojo::Crawler->new;
    $bot->discover($tx, Mojo::Crawler::Queue->new);
    my @array = @{$bot->{queues}};
    
    my $queue;
    $queue = shift @array;
    is $queue->literal_uri, 'css1.css', 'right url';
    is $queue->resolved_uri, 'http://example.com/css1.css', 'right url';
}

1;

__END__
