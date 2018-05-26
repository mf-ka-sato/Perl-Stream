use strict;
use warnings;
use utf8;
use Test::More;
use Data::Stream;
use Data::Stream::Cons;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1..20);
    my $filtered = $stream->filter(sub { $_[0] % 3 == 0 });

    is_deeply $filtered->to_arrayref, [3, 6, 9, 12, 15, 18];
    is_deeply $stream->to_arrayref, [1..20];                 # immutable
};

subtest 'all filtered' => sub {
    my $stream = Data::Stream->from_list(1..20);
    my $filtered = $stream->filter(sub { $_[0] == 0 });

    is_deeply $filtered->to_arrayref, [];
    is_deeply $stream->to_arrayref, [1..20]
};

subtest 'not filtered' => sub {
    my $stream = Data::Stream->from_list(1..20);
    my $filtered = $stream->filter(sub { defined $_[0] });

    is_deeply $filtered->to_arrayref, [1..20];
    is_deeply $stream->to_arrayref, [1..20];
};

subtest 'chain' => sub {
    my $stream = Data::Stream->from_list(1..20);
    my $filtered = $stream
        ->filter(sub { $_[0] % 5 != 0 })            # 1,2,3,4,6,7,8,9,11,...19
        ->filter(sub { $_[0] < 5 || 14 < $_[0] })   # 1,2,3,4,16,17,18,19
        ->filter(sub { $_[0] % 2 == 0 });           # 2,4,16,18

    is_deeply $filtered->to_arrayref, [2,4,16,18]
};

done_testing;
