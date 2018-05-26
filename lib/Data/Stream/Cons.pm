package Data::Stream::Cons;
use strict;
use warnings;
use utf8;

our $EMPTY = bless {}, 'Data::Stream::Cons';

sub new {
    my ($class, $value_f, $tail_f) =@_;
    bless {
        value_f => $value_f,
        value_cache => undef,
        tail_f => $tail_f,
        tail_cache => undef
    } => $class
}

sub value {
    my $self = shift;
    $self->{value_cache} //= $self->{value_f}->();
    $self->{value_cache};
}

sub tail {
    my $self = shift;
    $self->{tail_cache} //= $self->{tail_f}->();
    $self->{tail_cache};
}

1;
