use strict;
use warnings;
no warnings 'recursion';
use utf8;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..200);

    ok not $stream->forall(sub { $_[0] != 1 });
    ok not $stream->forall(sub { $_[0] != 200 });
    ok $stream->forall(sub { $_[0] <= 200 });
};

subtest 'inf length' => sub {
    my $stream = Data::Stream->from_vf(1, sub { $_[0] + 1 });

    ok not $stream->forall(sub { $_[0] < 1000 });
    ok not $stream->forall(sub { $_[0] != 10000 });
};

done_testing;
