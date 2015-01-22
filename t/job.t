use strict;
use warnings;
use utf8;
use File::Basename 'dirname';
use File::Spec::Functions qw{catdir splitdir rel2abs canonpath};
use lib catdir(dirname(__FILE__), '../lib');
use lib catdir(dirname(__FILE__), 'lib');
use Test::More;
use WWW::Crawler::Mojo::Job;

use Test::More tests => 6;

my $job = WWW::Crawler::Mojo::Job->new(resolved_uri => 'foo');
is $job->depth, 0;
my $job2 = $job->clone;
is $job2->resolved_uri, 'foo', 'right result';
is $job2->depth, 0;
my $job3 = $job->child;
is $job3->depth, 1;
my $job4 = $job->child;
is $job4->depth, 1;
my $job5 = $job4->child;
is $job5->depth, 2;

1;

__END__

