use strict;
use warnings;
use utf8;
use Test::More;

use Data::Stream;

subtest 'eq length' => sub {
    my $s1 = Data::Stream->from_list(1..100);
    my $s2 = Data::Stream->from_list(1..100)->map(sub { 1000 });
    my $zipped = $s1->zip_with($s2, sub { $_[0] + $_[1] });

    is_deeply $zipped->to_arrayref, [1001..1100];
    is_deeply $s1->to_arrayref, [1..100];
    is_deeply $s2->to_arrayref, [ map { 1000 } (1..100) ]
};

subtest 'different length' => sub {
    subtest '$s1 len < $s2 len' => sub {
        my $s1 = Data::Stream->from_list(0,1,0,1,0,1,0);
        my $s2 = Data::Stream->from_list(1,2,3,2,3,4,3,4,5);
        my $zipped = $s1->zip_with($s2, sub { $_[0] + $_[1] });

        is_deeply $zipped->to_arrayref, [1,3,3,3,3,5,3];

        subtest 'inf $s2 len' => sub {
            my $s1 = Data::Stream->from_list(1..100);
            my $s2 = Data::Stream->from_vf(0, sub { $_[0] });
            my $zipped = $s1->zip_with($s2, sub { $_[0] + $_[1] });

            is_deeply $zipped->to_arrayref, [1..100];
        };
    };

    subtest '$s1 len > $s2 len' => sub {
        my $s1 = Data::Stream->from_list(1,10,100,1000,10000,100000);
        my $s2 = Data::Stream->from_list(1, 2,  3,   4);
        my $zipped = $s1->zip_with($s2, sub { $_[0] + $_[1] });

        is_deeply $zipped->to_arrayref, [2,12,103,1004];

        subtest 'inf $s1 len' => sub {
            my $s1 = Data::Stream->from_vf(1, sub { $_[0] * 10 });
            my $s2 = Data::Stream->from_list(1,2,3,4,5);
            my $zipped = $s1->zip_with($s2, sub { $_[0] + $_[1] });

            is_deeply $zipped->to_arrayref, [2,12,103,1004,10005];
        };
    };

};

done_testing;
