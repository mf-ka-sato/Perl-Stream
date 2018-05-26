use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1,2,3);
    my $next = $stream->next;

    is_deeply $next, $stream;

    my $filtered = $stream->filter(sub { $_[0] % 2 == 0});
    my $filtered_next = $filtered->next;

    is $filtered_next->value, 2; 
};

done_testing;
