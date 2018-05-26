use strict;
use warnings;
use utf8;
use Test::More;
use Data::Stream;
use Data::Stream::Cons;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1,2,3);
    is_deeply $stream->to_arrayref, [1,2,3];
};

done_testing;
