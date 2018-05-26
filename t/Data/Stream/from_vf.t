use strict; 
use warnings;
use utf8;
use Test::More;
use Data::Stream;
use Data::Stream::Cons;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_vf(1, sub { $_[0] + 1 });
    my $taked_stream = $stream->take_while(sub { $_[0] <= 500 });

    is_deeply $taked_stream->to_arrayref, [1..500];
};

done_testing;
