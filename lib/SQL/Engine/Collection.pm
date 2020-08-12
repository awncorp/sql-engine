package SQL::Engine::Collection;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

# VERSION

# ATTRIBUTES

has items => (
  is => 'ro',
  isa => 'ArrayRef[Object]',
  new => 1
);

fun new_items($self) {
  []
}

# METHODS

method clear() {

  return @{$self->items} = ();
}

method count() {

  return scalar @{$self->items};
}

method each(CodeRef $value) {
  my $results = [];

  for my $item ($self->list) {
    push @$results, $value->($item);
  }

  return $results;
}

method first() {

  return $self->items->[0];
}

method last() {

  return $self->items->[1];
}

method list() {

  return wantarray ? (@{$self->items}) : $self->items;
}

method pop() {

  return CORE::pop @{$self->items};
}

method pull() {

  return shift @{$self->items};
}

method push(Object @values) {

  return CORE::push @{$self->items}, @values;
}

1;
