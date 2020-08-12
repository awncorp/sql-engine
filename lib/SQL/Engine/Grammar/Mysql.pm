package SQL::Engine::Grammar::Mysql;

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
  $self->operation($self->term(qw(start transaction)));

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
    push @$sql, $self->term('modify');

    # column name
    push @$sql, $self->name($data->{column}{name});

    # column tyoe
    push @$sql, $def->{type};

    # column (null | not null)
    push @$sql, $data->{column}{nullable}
      ? $self->term(qw(not null)) : $self->term(qw(not null));

    # sql statement
    join ' ', @$sql
  });

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
    push @$sql, $self->term(qw(alter column));

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

method column_definition(HashRef $data) {
  my $def = $self->next::method($data);

  if (exists $data->{default}) {
    $def->{default} = join ' ', $self->term('default'),
      sprintf '(%s)', $self->expression($data->{default});
  }

  if ($data->{increment}) {
    $def->{increment} = $self->term('auto_increment');
  }

  return $def;
}

method index_drop(HashRef $data) {
  my $sql = [];

  # drop
  push @$sql, $self->term('drop');

  # index
  push @$sql, $self->term('index');

  # index name
  push @$sql, $self->wrap($self->index_name($data));

  # table name
  push @$sql, $self->term('on'), $self->table($data->{for});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method transaction(HashRef $data) {
  my @mode;
  if ($data->{mode}) {
    @mode = map $self->term($_), @{$data->{mode}};
  }
  $self->operation($self->term('start', 'transaction', @mode));
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
  my $options = $data->{options} || [];

  return sprintf('char(%s)', $self->value($options->[0] || 1));
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
  my $options = $data->{options} || [];

  return sprintf(
    'decimal(%s)',
    join(', ',
      $self->value($options->[0]) || 5,
      $self->value($options->[1]) || 2)
  );
}

method type_double(HashRef $data) {
  my $options = $data->{options} || [];

  return sprintf(
    'double(%s)',
    join(', ',
      $self->value($options->[0]) || 5,
      $self->value($options->[1]) || 2)
  );
}

method type_enum(HashRef $data) {
  my $options = $data->{options};

  return sprintf('enum(%s)', join(', ', map $self->value($_), @$options));
}

method type_float(HashRef $data) {

  return $self->type_double($data);
}

method type_integer(HashRef $data) {

  return 'int';
}

method type_integer_big(HashRef $data) {

  return 'bigint';
}

method type_integer_big_unsigned(HashRef $data) {

  return join ' ', $self->type_integer_big($data), 'unsigned';
}

method type_integer_medium(HashRef $data) {

  return 'mediumint';
}

method type_integer_medium_unsigned(HashRef $data) {

  return join ' ', $self->type_integer_medium($data), 'unsigned';
}

method type_integer_small(HashRef $data) {

  return 'smallint';
}

method type_integer_small_unsigned(HashRef $data) {

  return join ' ', $self->type_integer_small($data), 'unsigned';
}

method type_integer_tiny(HashRef $data) {

  return 'tinyint';
}

method type_integer_tiny_unsigned(HashRef $data) {

  return join ' ', $self->type_integer_tiny($data), 'unsigned';
}

method type_integer_unsigned(HashRef $data) {

  return join ' ', $self->type_integer($data), 'unsigned';
}

method type_json(HashRef $data) {

  return 'json';
}

method type_number(HashRef $data) {

  return $self->type_integer($data);
}

method type_string(HashRef $data) {
  my $options = $data->{options} || [];

  return sprintf('varchar(%s)', $options->[0] || 255);
}

method type_text(HashRef $data) {

  return 'text';
}

method type_text_long(HashRef $data) {

  return 'longtext';
}

method type_text_medium(HashRef $data) {

  return 'mediumtext';
}

method type_time(HashRef $data) {

  return 'time';
}

method type_time_wtz(HashRef $data) {

  return 'time';
}

method type_timestamp(HashRef $data) {

  return 'timestamp';
}

method type_timestamp_wtz(HashRef $data) {

  return 'timestamp';
}

method type_uuid(HashRef $data) {

  return 'char(36)';
}

method view_create(HashRef $data) {
  my $sql = [];

  # create
  push @$sql, $self->term('create');

  # view
  push @$sql, $self->term('view');

  # safe
  if ($data->{safe}) {
    push @$sql, $self->term(qw(if not exists));
  }

  # view name
  push @$sql, $self->name($data->{name});

  # columns
  if (my $columns = $data->{columns}) {
    push @$sql,
      sprintf('(%s)', join(', ', map $self->expression($_), @$columns));
  }

  # query
  if (my $query = $data->{query}) {
    $self->select($query->{select});
    my $operation = $self->operations->pop;
    $self->{bindings} = $operation->bindings;
    push @$sql, $self->term('as');
    push @$sql, $operation->statement;
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method wrap(Str $name) {

  return qq(`$name`);
}

1;
