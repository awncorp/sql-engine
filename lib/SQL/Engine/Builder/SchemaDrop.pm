package SQL::Engine::Builder::SchemaDrop;

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
  req => 1
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

  if ($self->safe) {
    $schema->{"safe"} = $self->safe;
  }

  return {
    "schema-drop" => $schema
  }
}

1;
