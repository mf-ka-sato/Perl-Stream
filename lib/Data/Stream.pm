package Data::Stream;
use strict;
use warnings;
use utf8;
use List::Util qw/reduce/;
use Clone 'clone';
use Mouse;

use Data::Stream::Cons;
use Monad::Lazy;

use Data::Dumper;

has config => (
    is  => 'ro',
    isa => 'HashRef',
    default => sub { +{ 
        map_f => undef,
        filter_f => undef,
        take_while_f => undef
    } }
);

has cons => (
    is  => 'ro',
    isa => 'Data::Stream::Cons',
    default => sub { $Data::Stream::Cons::EMPTY }
);


sub from_list {
    my $class = shift;
    my $cons = $Data::Stream::Cons::EMPTY;

    for my $item (reverse @_) {
        my $old = $cons;
        $cons = Data::Stream::Cons->new(
            value => Monad::Lazy::mreturn($item),
            tail  =>Monad::Lazy::mreturn($old),
        );
    }
    Data::Stream->new(cons => $cons);
}

sub from_vf {
    my ($class, $v, $f) = @_;
    Data::Stream->new(
        cons => Data::Stream::Cons->new(
            value => Monad::Lazy::mreturn($v),
            tail  => Monad::Lazy->new(_gen => sub { Data::Stream->from_vf($f->($v), $f)->{cons} })
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
    
    return Data::Stream->new(
        cons => $Data::Stream::Cons::EMPTY,
        config => $self->{config}
        ) if not defined $cons;

    while ($cons != $Data::Stream::Cons::EMPTY) {
        my $value = $map_f->($cons->value->eval);

        return Data::Stream->new(cons => $Data::Stream::Cons::EMPTY) if not $take_while_f->($value);
        return Data::Stream->new(cons => $cons, config => $config) if $filter_f->($value);

        $cons = $cons->tail->eval;
    }
    return Data::Stream->new(cons => $cons, config => $config);
}

# 自分を含めずに次に有効な要素を先頭とするStreamを返す
# 有効な要素が見つからない場合は$Data::Stream::Cons::EMPTYのStreamを返す
sub tail {
    my $self = shift;
    return $self if $self->is_empty; 
    my $tail = $self->{cons}->tail->eval;
    return Data::Stream->new(cons => $tail, config => $self->{config})->next;
}


sub value {
    my $self = shift;
    my $map_f = $self->{config}->{map_f} // sub { shift };
    return $map_f->($self->{cons}->value->eval);
}

sub is_empty {
    my $self = shift;
    return $self->{cons} == $Data::Stream::Cons::EMPTY;
}

###### collection methoods ######

##### register methods #####
# 情報登録系メソッド
# メソッド実行時には関数の登録を行い、
# 値を取り出す際にその関数を適用する

sub map {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{map_f}) {
        my $old_f = $conf->{map_f};
        $conf->{map_f} = sub { $f->($old_f->($_[0])) };
    } else {
        $conf->{map_f} = $f;
    }

    Data::Stream->new(cons => $self->{cons}, config => $conf);
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

    Data::Stream->new(cons => $self->{cons}, config => $conf);
}

sub take_while {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{take_while_f}) {
        $conf->{take_while_f} = sub { $conf->{take_while_f}->($_[0]) && $f->($_[0]) }
    } else {
        $conf->{take_while_f} = $f;
    }

    Data::Stream->new(cons => $self->{cons}, config => $conf);
}

##### iterate methods #####

sub foreach: method {
    my ($self, $f) = @_;
    my $stream = $self->next;

    while (not $stream->is_empty) {
        $f->($stream->value);
        $stream = $stream->tail;
    }
    return;
}

##### fold methods #####
# 要素を1つの値にまとめるメソッド

sub foldl {
    my ($self, $acc, $f) = @_;
    my $call_next = not defined shift;
    my $stream = $call_next ? $self->next : $self;

    return $acc if $stream->is_empty;
    @_ = ($stream->tail, $f->($acc, $stream->value), $f, 1);
    goto &foldl;
}

# 遅延評価使えば無限リストに対しても動作するfoldr作れそう
sub foldr {
    my ($self, $f, $acc) = @_;
    # $f :: a -> Monad::Lazy(b) -> b

    my $call_next = not defined shift;
    my $stream = $call_next ? $self->next : $self;

    return $acc if $stream->is_empty;

    no warnings 'recursion';
    my $value = $stream->value;
    my $lazy_tail = Monad::Lazy->new(_gen => sub { $stream->tail->foldr($f, $acc, 1) });

    $f->($value, $lazy_tail);
}

sub forall {
    my ($self, $f) = @_;
    # $f :: Function(Any -> Bool)
    my $stream = $self->next;

    while (not $stream->is_empty) {
        return 0 if not $f->($stream->value);
        $stream = $stream->tail;
    }
    return 1;
}

sub exists {
    my ($self, $f) = @_;
    # $f :: Function(Any -> Bool)
    my $stream = $self->next;

    while (not $stream->is_empty) {
        return 1 if $f->($stream->value);
        $stream = $stream->tail;
    }
    return 0;
}

sub to_arrayref {
    my $self = shift;
    my @arr;
    $self->foreach(sub { push @arr, $_[0] });
    \@arr;
}

#### merge methods ####

sub zip_with {
    my ($st1, $st2, $zip_f) = @_;
    # $zip_f :: Function($st1 -> $st2 -> Any)
    my $call_next = not defined shift;
    if ($call_next) {
        $st1 = $st1->next;
        $st2 = $st2->next;
    }

    return Data::Stream->new(cons => $Data::Stream::Cons::EMPTY)
        if $st1->is_empty or $st2->is_empty; 

    Data::Stream->new(
        cons => Data::Stream::Cons->new(
            value => Monad::Lazy::gen(sub { $zip_f->($st1->value, $st2->value) }),
            tail  => Monad::Lazy::gen(sub { $st1->tail->zip_with($st2->tail, $zip_f, 1)->{cons} })
        )
    );
}


1;
