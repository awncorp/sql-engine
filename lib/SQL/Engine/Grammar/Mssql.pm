package SQL::Engine::Grammar::Mssql;

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
  $self->operation($self->term(qw(begin transaction)));

  my $def = $self->column_definition($data->{column});

  # column type
  $self->operation(do {
    my $sql = [];

    # alter table
    push @$sql, $self->term(qw(alter table));

    # safe
    push @$sql, $self->term(qw(if exists)) if $data->{safe};

    # for
    push @$sql, $self->table($data->{for});

    # alter column
    push @$sql, $self->term('alter');

    # column name
    push @$sql, $self->name($data->{column}{name});

    # column tyoe
    push @$sql, $self->term('type'), $def->{type};

    # sql statement
    join ' ', @$sql
  });

  # column nullable
  if (exists $data->{column}{nullable}) {
    $self->operation(do {
        my $sql = [];

        # alter table
        push @$sql, $self->term(qw(alter table));

        # safe
        push @$sql, $self->term(qw(if exists)) if $data->{safe};

        # for
        push @$sql, $self->table($data->{for});

        # alter column
        push @$sql, $self->term('alter');

        # column name
        push @$sql, $self->name($data->{column}{name});

        # column (set | drop) not null
        push @$sql,
          $data->{column}{nullable}
          ? ($self->term('drop'), $self->term(qw(not null)))
          : ($self->term('set'), $self->term(qw(not null)));

        # sql statement
        join ' ', @$sql
      });
  }

  # column default
  $self->operation(do {
    my $sql = [];

    # alter table
    push @$sql, $self->term(qw(alter table));

    # safe
    push @$sql, $self->term(qw(if exists)) if $data->{safe};

    # for
    push @$sql, $self->table($data->{for});

    # alter column
    push @$sql, $self->term('alter');

    # column name
    push @$sql, $self->name($data->{column}{name});

    # column (set | drop) default
    push @$sql,
      $data->{column}{default}
      ? ($self->term('set'), $def->{default})
      : ($self->term('drop'), $self->term('default'));

    # sql statement
    join ' ', @$sql
  });

  $self->operation($self->term('commit'));

  return $self;
}

method transaction(HashRef $data) {
  my @mode;
  if ($data->{mode}) {
    @mode = map $self->term($_), @{$data->{mode}};
  }
  $self->operation($self->term('begin', 'transaction', @mode));
  $self->process($_) for @{$data->{queries}};
  $self->operation($self->term('commit'));

  return $self;
}

method type_binary(HashRef $data) {

  return 'varbinary(max)';
}

method type_boolean(HashRef $data) {

  return 'bit';
}

method type_char(HashRef $data) {
  my $options = $data->{options} || [];

  return sprintf('nchar(%s)', $self->value($options->[0] || 1));
}

method type_date(HashRef $data) {

  return 'date';
}

method type_datetime(HashRef $data) {

  return 'datetime';
}

method type_datetime_wtz(HashRef $data) {

  return 'datetimeoffset(0)';
}

method type_decimal(HashRef $data) {
  my $options = $data->{options} || [];

  return sprintf(
    'decimal(%s)',
    join(', ',
      $self->value($options->[0]) || 5,
      $self->value($options->[1]) || 2)
  );
}

method type_double(HashRef $data) {

  return 'float';
}

method type_enum(HashRef $data) {

  return 'nvarchar(255)';
}

method type_float(HashRef $data) {

  return 'float';
}

method type_integer(HashRef $data) {

  return 'int';
}

method type_integer_big(HashRef $data) {

  return 'bigint';
}

method type_integer_big_unsigned(HashRef $data) {

  return $self->type_integer_big($data);
}

method type_integer_medium(HashRef $data) {

  return 'int';
}

method type_integer_medium_unsigned(HashRef $data) {

  return $self->type_integer_medium($data);
}

method type_integer_small(HashRef $data) {

  return 'smallint';
}

method type_integer_small_unsigned(HashRef $data) {

  return $self->type_integer_small($data);
}

method type_integer_tiny(HashRef $data) {

  return 'tinyint';
}

method type_integer_tiny_unsigned(HashRef $data) {

  return $self->type_integer_tiny($data);
}

method type_integer_unsigned(HashRef $data) {

  return $self->type_integer($data);
}

method type_json(HashRef $data) {

  return 'nvarchar(max)';
}

method type_number(HashRef $data) {

  return $self->type_integer($data);
}

method type_string(HashRef $data) {
  my $options = $data->{options} || [];

  return sprintf('nvarchar(%s)', $options->[0] || 255);
}

method type_text(HashRef $data) {

  return 'nvarchar(max)';
}

method type_text_long(HashRef $data) {

  return 'nvarchar(max)';
}

method type_text_medium(HashRef $data) {

  return 'nvarchar(max)';
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

  return 'datetimeoffset(0)';
}

method type_uuid(HashRef $data) {

  return 'uniqueidentifier';
}

method wrap(Str $name) {

  return qq([$name]);
}

1;
