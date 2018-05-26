use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..100);

    is $stream->foldl(0, sub { $_[0] + $_[1] }), 5050;
};

done_testing;
