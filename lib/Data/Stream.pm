package Data::Stream;
use strict;
use warnings;
use utf8;
use Clone 'clone';

sub new {
    my $class = shift;
    my $cons = shift;
    bless {
        config => {
            map_f => undef,
            filter_f => undef,
            take_while_f => undef
        },
        cons => $cons
    } => $class
}



#### collection methoods ####

sub map {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{map_f}) {
        $conf->{map_f} = sub { $f->($conf->{map_f}->($_[0])) };
    } else {
        $conf->{map_f} = $f;
    }

    Data::Stream->new($conf, $self->{cons});
}

sub filter {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{filter_f}) {
        $conf->{filter_f} = sub { $conf->{filter_f}->($_[0]) && $f->($_[0]) }
    } else {
        $conf->{filter_f} = $f;
    }

    Data::Stream->new($conf, $self);
}

sub take_while {
    my ($self, $f) = @_;
    my $conf = clone $self->{config};

    if (defined $conf->{take_while_f}) {
        $conf->{take_while_f} = sub { $conf->{take_while_f}->($_[0]) && $f->($_[0]) }
    } else {
        $conf->{take_while_f} = $f;
    }

    Data::Stream->new($conf, $self);
}

1;
