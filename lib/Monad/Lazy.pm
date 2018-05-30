package Monad::Lazy;
use strict;
use warnings;
use utf8;
use Mouse;

# properties

has _value => (
    is  => 'rw',
    default => undef
);

has _gen => (
    is  => 'ro',
    isa => 'CodeRef'
);

# Monad Functions

sub mreturn {
    my $v = shift;
    Monad::Lazy->new(_value => $v, _gen => sub { $v });
}

sub gen {
    Monad::Lazy->new(_gen => shift);
}

# methods

sub eval {
    my $self = shift;

    $self->_value($self->_gen->()) if not defined $self->_value;
    $self->_value;
}

sub map {
    my ($self, $f) = @_;
    Monad::Lazy->new(_gen => sub { $f->($self->eval) });
}

sub flatmap {
    my ($self, $f) = @_;
    # $f :: a -> Monad::Lazy(a)

    Monad::Lazy->new(_gen => sub { $f->($self->eval)->eval });
}


1;
