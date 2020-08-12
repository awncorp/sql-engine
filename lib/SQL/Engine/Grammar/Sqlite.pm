package SQL::Engine::Grammar::Sqlite;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;

extends 'SQL::Engine::Grammar';

# VERSION

# METHODS

method column_change(HashRef $data) {
  my $name = $data->{column}{name};
  my $tempname = join '_', $name, 'discarded', time;

  $self->operation($self->term(qw(begin transaction)));

  # rename column
  $self->column_rename({
    for => $data->{for},
    name => {
      new => $tempname,
      old => $name
    }
  });

  # re-create column
  $self->column_create($data);

  # copy data from column to column
  $self->update({
    for => $data->{for},
    columns => [{
      column => $name,
      value => {column => $tempname}
    }]
  });

  # nullify data from discardd
  $self->update({
    for => $data->{for},
    columns => [{
      column => $tempname,
      value => undef
    }]
  });

  $self->operation($self->term('commit'));

  return $self;
}

method column_definition(HashRef $data) {
  my $def = $self->next::method($data);

  if ($data->{increment}) {
    $def->{increment} = $self->term('autoincrement');
  }

  return $def;
}

method table_drop(HashRef $data) {
  my $sql = [];

  # drop table
  push @$sql, $self->term(qw(drop table)),
    ($data->{safe} ? $self->term(qw(if exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method transaction(HashRef $data) {
  my @mode;
  if ($data->{mode}) {
    @mode = map $self->term($_), @{$data->{mode}};
  }
  $self->operation($self->term('begin', @mode, 'transaction'));
  $self->process($_) for @{$data->{queries}};
  $self->operation($self->term('commit'));

  return $self;
}

method type_binary(HashRef $data) {

  return 'blob';
}

method type_boolean(HashRef $data) {

  return 'tinyint(1)';
}

method type_char(HashRef $data) {

  return 'varchar';
}

method type_date(HashRef $data) {

  return 'date';
}

method type_datetime(HashRef $data) {

  return 'datetime';
}

method type_datetime_wtz(HashRef $data) {

  return 'datetime';
}

method type_decimal(HashRef $data) {

  return 'numeric';
}

method type_double(HashRef $data) {

  return 'float';
}

method type_enum(HashRef $data) {

  return 'varchar';
}

method type_float(HashRef $data) {

  return 'float';
}

method type_integer(HashRef $data) {

  return 'integer';
}

method type_integer_big(HashRef $data) {

  return 'integer';
}

method type_integer_big_unsigned(HashRef $data) {

  return 'integer';
}

method type_integer_medium(HashRef $data) {

  return 'integer';
}

method type_integer_medium_unsigned(HashRef $data) {

  return 'integer';
}

method type_integer_small(HashRef $data) {

  return 'integer';
}

method type_integer_small_unsigned(HashRef $data) {

  return 'integer';
}

method type_integer_tiny(HashRef $data) {

  return 'integer';
}

method type_integer_tiny_unsigned(HashRef $data) {

  return 'integer';
}

method type_integer_unsigned(HashRef $data) {

  return 'integer';
}

method type_json(HashRef $data) {

  return 'text';
}

method type_number(HashRef $data) {

  return $self->type_integer($data);
}

method type_string(HashRef $data) {

  return 'varchar';
}

method type_text(HashRef $data) {

  return 'text';
}

method type_text_long(HashRef $data) {

  return 'text';
}

method type_text_medium(HashRef $data) {

  return 'text';
}

method type_time(HashRef $data) {

  return 'time';
}

method type_time_wtz(HashRef $data) {

  return 'time';
}

method type_timestamp(HashRef $data) {

  return 'datetime';
}

method type_timestamp_wtz(HashRef $data) {

  return 'datetime';
}

method type_uuid(HashRef $data) {

  return 'varchar';
}

method wrap(Str $name) {

  return qq("$name");
}

1;
