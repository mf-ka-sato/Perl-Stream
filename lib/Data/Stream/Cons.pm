package Data::Stream::Cons;
use strict;
use warnings;
use utf8;

sub new {
    my ($class, $value_f, $tail_f) =@_;
    bless {
        value_f => $value_f,
        value_cache => undef,
        tail_f => $tail_f,
        tail_cache => undef
    } => $class
}

1;
