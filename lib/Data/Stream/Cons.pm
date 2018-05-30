package Data::Stream::Cons;
use strict;
use warnings;
use utf8;
use Mouse;

use Monad::Lazy;

our $EMPTY = bless {}, 'Data::Stream::Cons';


has value => (
    is  => 'ro',
    isa => 'Monad::Lazy',
    required => 1
);

has tail => (
    is  => 'ro',
    isa => 'Monad::Lazy',
    required => 1
);

1;
