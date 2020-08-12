package SQL::Engine::Builder::IndexCreate;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

extends 'SQL::Engine::Builder';

use SQL::Validator;

# VERSION

# ATTRIBUTES

has name => (
  is => 'ro',
  isa => 'Str',
  opt => 1
);

has for => (
  is => 'ro',
  isa => 'HashRef',
  req => 1
);

has columns => (
  is => 'ro',
  isa => 'ArrayRef[HashRef]',
  req => 1
);

has unique => (
  is => 'ro',
  isa => 'Bool',
  opt => 1
);

has safe => (
  is => 'ro',
  isa => 'Bool',
  opt => 1
);

# METHODS

method data() {
  my $schema = {};

  if ($self->name) {
    $schema->{"name"} = $self->name;
  }

  if ($self->for) {
    $schema->{"for"} = $self->for;
  }

  if ($self->columns) {
    $schema->{"columns"} = $self->columns;
  }

  if ($self->unique) {
    $schema->{"unique"} = $self->unique;
  }

  if ($self->safe) {
    $schema->{"safe"} = $self->safe;
  }

  return {
    "index-create" => $schema
  }
}

1;
