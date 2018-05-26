use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..100);

    ok $stream->forall(sub { $_[0] <= 100 });
    ok not $stream->forall(sub { $_[0] != 100 });
};

done_testing;
