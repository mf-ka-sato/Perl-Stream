package Data::Stream;
use strict;
use warnings;
no warnings 'recursion';
use utf8;
use List::Util qw/reduce/;
use Clone 'clone';

use Data::Stream::Cons;

use Data::Dumper;

sub new {
    my ($class, $cons, $config) = @_;
    
    $cons //= $Data::Stream::Cons::EMPTY;
    $config //= +{
        map_f => undef,
        filter_f => undef,
        take_while_f => undef
    };

    bless +{
        cons => $cons,
        config => $config
    } => $class
}

sub from_list {
    my $class = shift;
    my $cons = $Data::Stream::Cons::EMPTY;

    for my $item (reverse @_) {
        my $old = $cons;
        $cons = Data::Stream::Cons->new(
            sub { $item },
            sub { $old }
        );
    }
    Data::Stream->new($cons);
}

sub from_vf {
    my ($class, $v, $f) = @_;
    Data::Stream->new(
        Data::Stream::Cons->new(
            sub { $v },
            sub { Data::Stream->from_vf($f->($v), $f)->{cons} }
        )
    );
}

###### basic methods ######

# 自分を含めて次に有効な要素を返す
# 有効な要素が見つからない場合は$Data::Stream::Cons::EMPTYを返す
sub next {
    my $self = shift;
    my $cons = $self->{cons};
    my $config = $self->{config};
    
    my $map_f = $config->{map_f} // sub { shift };
    my $take_while_f = $config->{take_while_f} // sub { 1 };
    my $filter_f = $config->{filter_f} // sub { 1 };
    
    return Data::Stream->new($Data::Stream::Cons::EMPTY, $self->{config}) if not defined $cons;

    while ($cons != $Data::Stream::Cons::EMPTY) {
        my $value = $map_f->($cons->value);

        return Data::Stream->new($Data::Stream::Cons::EMPTY) if not $take_while_f->($value);
        return Data::Stream->new($cons, $config) if $filter_f->($value);

        $cons = $cons->tail;
    }
    return Data::Stream->new($cons);
}

# 自分を含めずに次に有効な要素を先頭とするStreamを返す
# 有効な要素が見つからない場合は$Data::Stream::Cons::EMPTYのStreamを返す
sub tail {
    my $self = shift;
    return $self if $self->{cons} == $Data::Stream::Cons::EMPTY;
    return Data::Stream->new($self->{cons}->tail, $self->{config})->next;
}


sub value {
    my $self = shift;
    my $map_f = $self->{config}->{map_f} // sub { shift };
    return $map_f->($self->{cons}->value);
}

###### collection methoods ######

##### register methods #####

sub map {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{map_f}) {
        my $old_f = $conf->{map_f};
        $conf->{map_f} = sub { $f->($old_f->($_[0])) };
    } else {
        $conf->{map_f} = $f;
    }

    Data::Stream->new($self->{cons}, $conf);
}

sub filter {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{filter_f}) {
        my $old_f = $conf->{filter_f};
        $conf->{filter_f} = sub { $old_f->($_[0]) && $f->($_[0]) }
    } else {
        $conf->{filter_f} = $f;
    }

    Data::Stream->new($self->{cons}, $conf);
}

sub take_while {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{take_while_f}) {
        $conf->{take_while_f} = sub { $conf->{take_while_f}->($_[0]) && $f->($_[0]) }
    } else {
        $conf->{take_while_f} = $f;
    }

    Data::Stream->new($self->{cons}, $conf);
}

##### iterate methods #####

sub foreach: method {
    my ($self, $f) = @_;
    my $stream = $self->next;

    while ($stream->{cons} != $Data::Stream::Cons::EMPTY) {
        $f->($stream->value);
        $stream = $stream->tail;
    }
    return;
}

##### fold methods #####

sub foldl {
    my ($self, $acc, $f) = @_;
    my $call_next = not defined shift;
    my $stream = $call_next ? $self->next : $self;

    return $acc if $stream->{cons} == $Data::Stream::Cons::EMPTY;
    @_ = ($stream->tail, $f->($acc, $stream->value), $f, 1);
    goto &foldl;
}

# 遅延評価使えば無限リストに対しても動作するfoldr作れそう
sub foldr {
    my ($self, $f, $acc) = @_;
    # $f :: a -> b -> b
    my $call_next = not defined shift;

    $f->()
}

sub forall {
    my ($self, $f) = @_;
    # $f :: Function(Any -> Bool)
    
    $self->foldl(1, sub { $_[0] && $f->($_[1]) });
}

sub exists {
    my ($self, $f) = @_;
    # $f :: Function(Any -> Bool)
    
    $self->foldl(0, sub { $_[0] || $f->($_[1]) });
}

sub to_arrayref {
    my $self = shift;
    my @arr;
    $self->foreach(sub { push @arr, $_[0] });
    \@arr;
}

1;
