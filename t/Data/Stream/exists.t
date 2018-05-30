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

subtest 'inf length' => sub {
    my $stream = Data::Stream->from_vf(1, sub { $_[0] + 1 });

    ok $stream->exists(sub { $_[0] == 500 });
    ok $stream->exists(sub { $_[0] >  1000 })
};

done_testing;
