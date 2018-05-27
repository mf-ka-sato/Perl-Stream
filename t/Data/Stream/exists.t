use strict;
use warnings;
use utf8;
use Test::More;
use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..100);

    ok $stream->exists(sub { $_[0] == 99 });
    ok not $stream->exists(sub { $_[0] < 0 });
    ok not $stream->exists(sub { $_[0] > 100 });
};

done_testing;
