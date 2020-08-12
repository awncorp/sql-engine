package SQL::Engine::Builder::TableRename;

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
  isa => 'HashRef',
  req => 1
);

# METHODS

method data() {
  my $schema = {};

  if ($self->name) {
    $schema->{"name"} = $self->name;
  }

  return {
    "table-rename" => $schema
  }
}

1;
