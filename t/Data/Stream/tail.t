use strict;
use warnings;
use utf8;
use Test::More;
use Test::Exception;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1,2,3);

    is $stream->tail->value, 2;
    is $stream->tail->tail->value, 3;
    dies_ok { $stream->tail->tail->tail->value };
};

done_testing;
