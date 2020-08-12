package SQL::Engine;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

use SQL::Engine::Collection;
use SQL::Validator;

# VERSION

# ATTRIBUTES

has grammar => (
  is  => 'ro',
  isa => 'Str',
  opt => 1
);

has operations => (
  is  => 'ro',
  isa => 'InstanceOf["SQL::Engine::Collection"]',
  new => 1
);

fun new_operations($self) {

  SQL::Engine::Collection->new;
}

has validator => (
  is => 'ro',
  isa => 'Maybe[InstanceOf["SQL::Validator"]]',
  new => 1
);

fun new_validator($self) {
  SQL::Validator->new(
    $ENV{SQL_ENGINE_SCHEMA}
    ? (schema => $ENV{SQL_ENGINE_SCHEMA})
    : (version => '0.0')
  )
}

# METHODS

method column_change(@args) {
  require SQL::Engine::Builder::ColumnChange;

  my $grammar = SQL::Engine::Builder::ColumnChange->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method column_create(@args) {
  require SQL::Engine::Builder::ColumnCreate;

  my $grammar = SQL::Engine::Builder::ColumnCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method column_drop(@args) {
  require SQL::Engine::Builder::ColumnDrop;

  my $grammar = SQL::Engine::Builder::ColumnDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method column_rename(@args) {
  require SQL::Engine::Builder::ColumnRename;

  my $grammar = SQL::Engine::Builder::ColumnRename->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method constraint_create(@args) {
  require SQL::Engine::Builder::ConstraintCreate;

  my $grammar = SQL::Engine::Builder::ConstraintCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method constraint_drop(@args) {
  require SQL::Engine::Builder::ConstraintDrop;

  my $grammar = SQL::Engine::Builder::ConstraintDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method database_create(@args) {
  require SQL::Engine::Builder::DatabaseCreate;

  my $grammar = SQL::Engine::Builder::DatabaseCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method database_drop(@args) {
  require SQL::Engine::Builder::DatabaseDrop;

  my $grammar = SQL::Engine::Builder::DatabaseDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method delete(@args) {
  require SQL::Engine::Builder::Delete;

  my $grammar = SQL::Engine::Builder::Delete->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method index_create(@args) {
  require SQL::Engine::Builder::IndexCreate;

  my $grammar = SQL::Engine::Builder::IndexCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method index_drop(@args) {
  require SQL::Engine::Builder::IndexDrop;

  my $grammar = SQL::Engine::Builder::IndexDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method insert(@args) {
  require SQL::Engine::Builder::Insert;

  my $grammar = SQL::Engine::Builder::Insert->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method schema_create(@args) {
  require SQL::Engine::Builder::SchemaCreate;

  my $grammar = SQL::Engine::Builder::SchemaCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method schema_drop(@args) {
  require SQL::Engine::Builder::SchemaDrop;

  my $grammar = SQL::Engine::Builder::SchemaDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method schema_rename(@args) {
  require SQL::Engine::Builder::SchemaRename;

  my $grammar = SQL::Engine::Builder::SchemaRename->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method select(@args) {
  require SQL::Engine::Builder::Select;

  my $grammar = SQL::Engine::Builder::Select->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method table_create(@args) {
  require SQL::Engine::Builder::TableCreate;

  my $grammar = SQL::Engine::Builder::TableCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method table_drop(@args) {
  require SQL::Engine::Builder::TableDrop;

  my $grammar = SQL::Engine::Builder::TableDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method table_rename(@args) {
  require SQL::Engine::Builder::TableRename;

  my $grammar = SQL::Engine::Builder::TableRename->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method transaction(@args) {
  require SQL::Engine::Builder::Transaction;

  my $grammar = SQL::Engine::Builder::Transaction->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method update(@args) {
  require SQL::Engine::Builder::Update;

  my $grammar = SQL::Engine::Builder::Update->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method view_create(@args) {
  require SQL::Engine::Builder::ViewCreate;

  my $grammar = SQL::Engine::Builder::ViewCreate->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

method view_drop(@args) {
  require SQL::Engine::Builder::ViewDrop;

  my $grammar = SQL::Engine::Builder::ViewDrop->new(@args)->grammar(
    grammar => $self->grammar,
    validator => $self->validator
  );

  $self->operations->push($grammar->execute->operations->list);

  return $self;
}

1;
