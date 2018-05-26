use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;
use Data::Stream::Cons;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..10);
    my $mapped = $stream->map(sub { $_[0] + 1 });

    is_deeply $mapped->to_arrayref, [2..11];
    is_deeply $stream->to_arrayref, [1..10];    # immutable
};

subtest 'identity' => sub {
    my $stream = Data::Stream->from_list(1..10);
    my $mapped_by_identity = $stream->map(sub { shift });

    is_deeply $stream->to_arrayref, $mapped_by_identity->to_arrayref;   # mapする関数がidentityなら元のStreamと等価
};

subtest 'chain' => sub {
    my $stream = Data::Stream->from_list(1..10);
    my $mapped = 
        $stream
            ->map(sub { $_[0] + 1 })
            ->map(sub { $_[0] * 2 })
            ->map(sub { $_[0] + 2 });

    is_deeply $mapped->to_arrayref, [6,8,10,12,14,16,18,20,22,24];
    is_deeply $stream->to_arrayref, [1..10];
};


done_testing;
