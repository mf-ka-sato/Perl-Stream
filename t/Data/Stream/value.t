use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    my $stream = Data::Stream->from_list(1);

    is $stream->value, 1;
};

subtest 'mapped' => sub {
    my $stream = Data::Stream->from_list(2);
    my $mapped = $stream->map(sub { $_[0] * 10 });

    is $mapped->value, 20;
};

done_testing;
