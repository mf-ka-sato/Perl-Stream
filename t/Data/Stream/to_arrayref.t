use strict;
use warnings;
use utf8;
use Test::More;
use Data::Stream;
use Data::Stream::Cons;

my $stream = Data::Stream->from_list(1..100);

is_deeply(
    $stream
        ->to_arrayref
    ,
    [ 1..100 ]
);


done_testing;
