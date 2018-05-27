use strict;
use warnings;
use strict;
use Test::More;

use Data::Stream;

subtest 'basic' => sub {
    ok not Data::Stream->from_list(1)->is_empty;
    ok not Data::Stream->from_vf(1, sub { $_[0] + 1 })->is_empty;
    ok    (Data::Stream->from_list()->is_empty);
};

done_testing;
