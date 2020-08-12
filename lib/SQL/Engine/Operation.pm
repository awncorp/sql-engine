package SQL::Engine::Operation;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

# VERSION

# ATTRIBUTES

has bindings => (
  is => 'ro',
  isa => 'HashRef',
  req => 1
);

has statement => (
  is => 'ro',
  isa => 'Str',
  req => 1
);

# METHODS

method parameters(Maybe[HashRef] $values) {
  my $bindings = $self->bindings;
  my @binddata = map $values->{$bindings->{$_}}, sort(keys(%$bindings));

  return wantarray ? (@binddata) : [@binddata];
}

1;
