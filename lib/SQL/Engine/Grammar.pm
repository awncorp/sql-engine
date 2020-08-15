package SQL::Engine::Grammar;

use 5.014;

use strict;
use warnings;

use registry;
use routines;

use Data::Object::Class;
use Data::Object::ClassHas;

use SQL::Engine::Collection;
use SQL::Engine::Operation;
use SQL::Validator;

use Scalar::Util ();

# VERSION

# ATTRIBUTES

has operations => (
  is  => 'ro',
  isa => 'InstanceOf["SQL::Engine::Collection"]',
  new => 1
);

fun new_operations($self) {

  SQL::Engine::Collection->new;
}

has schema => (
  is => 'ro',
  isa => 'HashRef',
  req => 1
);

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

method binding(Str $name) {
  $self->{bindings}{int(keys(%{$self->{bindings}}))} = $name;

  return '?';
}

method column_change(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # for
  push @$sql, $self->table($data->{for});

  # column
  push @$sql, $self->term(qw(alter column));

  # column specification
  push @$sql, $self->column_specification($data->{column});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method column_create(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # for
  push @$sql, $self->table($data->{for});

  # column
  push @$sql, $self->term(qw(add column));

  # column specification
  push @$sql, $self->column_specification($data->{column});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method column_definition(HashRef $data) {
  my $def = {};

  if ($data->{name}) {
    $def->{name} = $self->name($data->{name});
  }

  if ($data->{type}) {
    $def->{type} = $self->type($data);
  }

  if (exists $data->{default}) {
    $def->{default} = join ' ', $self->term('default'),
      $self->expression($data->{default});
  }

  if (exists $data->{nullable}) {
    $def->{nullable}
      = $data->{nullable} ? $self->term('null') : $self->term(qw(not null));
  }

  if ($data->{primary}) {
    $def->{primary} = $self->term(qw(primary key));
  }

  return $def;
}

method column_drop(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # table name
  push @$sql, $self->table($data);

  # drop column
  push @$sql, $self->term(qw(drop column));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # column name
  push @$sql, $self->name($data->{column});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method column_specification(HashRef $data) {
  my $sql = [];

  my $column = $self->column_definition($data);

  # name
  push @$sql, $column->{name};

  # type
  push @$sql, $column->{type};

  # nullable
  push @$sql, $column->{nullable} if $column->{nullable};

  # default
  push @$sql, $column->{default} if $column->{default};

  # primary
  push @$sql, $column->{primary} if $column->{primary};

  # increments
  push @$sql, $column->{increment} if $column->{increment};

  # sql statement
  return join ' ', @$sql;
}

method column_rename(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # table name
  push @$sql, $self->table($data->{"for"});

  # rename column
  push @$sql, $self->term(qw(rename column)),
    $self->name($data->{name}{old}),
    $self->term('to'),
    $self->name($data->{name}{new});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method constraint_create(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # table name
  push @$sql, $self->table($data->{source});

  # add constraint
  push @$sql, $self->term(qw(add constraint));

  # constraint name
  push @$sql, $self->name($self->constraint_name($data));

  # foreign key
  push @$sql, $self->term(qw(foreign key));

  # column name
  push @$sql, sprintf('(%s)', $self->name($data->{source}{column}));

  # references
  push @$sql, $self->term('references');

  # foreign table and column name
  push @$sql, sprintf('%s (%s)', $self->table($data->{target}),
    $self->name($data->{target}{column}));

  # reference option (on delete)
  if ($data->{on}{delete}) {
    push @$sql, $self->term(qw(on delete)),
      $self->constraint_option($data->{on}{delete});
  }

  # reference option (on update)
  if ($data->{on}{update}) {
    push @$sql, $self->term(qw(on update)),
      $self->constraint_option($data->{on}{update});
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method constraint_drop(HashRef $data) {
  my $sql = [];

  # alter table
  push @$sql, $self->term(qw(alter table));

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # table name
  push @$sql, $self->table($data->{source});

  # drop constraint
  push @$sql, $self->term(qw(drop constraint));

  # constraint name
  push @$sql, $self->name($self->constraint_name($data));

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method constraint_name(HashRef $data) {

  return $data->{name} || join('_', 'foreign',
    join('_', grep {defined} @{$data->{source}}{qw(schema table column)}),
    join('_', grep {defined} @{$data->{target}}{qw(schema table column)})
  );
}

method constraint_option(Str $name) {
  if (lc($name) eq "cascade") {
    return $self->term('cascade');
  }
  elsif (lc($name) eq "no-action") {
    return $self->term(qw(no action));
  }
  elsif (lc($name) eq "restrict") {
    return $self->term('restrict');
  }
  elsif (lc($name) eq "set-default") {
    return $self->term(qw(set default));
  }
  elsif (lc($name) eq "set-null") {
    return $self->term(qw(set null));
  }
  else {
    return $self->term(qw(no action));
  }
}

method criteria(ArrayRef $data) {

  return [map $self->criterion($_), @$data];
}

method criterion(HashRef $data) {
  if (my $cond = $data->{"and"}) {
    return sprintf('(%s)',
      join(sprintf(' %s ', $self->term('and')), @{$self->criteria($cond)}));
  }

  if (my $cond = $data->{"eq"}) {
    return sprintf '%s = %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"glob"}) {
    return sprintf '%s %s %s', $self->expression($cond->[0]),
      $self->term('glob'), $self->expression($cond->[1]);
  }

  if (my $cond = $data->{"gt"}) {
    return sprintf '%s > %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"gte"}) {
    return sprintf '%s >= %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"in"}) {
    return sprintf '%s %s %s', $self->expression($cond->[0]),
      $self->term('in'), join ', ', map $self->expression($_),
      @$cond[1 .. $#$cond];
  }

  if (my $cond = $data->{"is"}) {
    return sprintf '(%s)',
      (ref($cond) eq 'HASH')
        ? $self->expression($cond)
        : join(sprintf(' %s ', $self->term('and')), @{$self->criteria($cond)});
  }

  if (my $cond = $data->{"is-null"}) {
    return sprintf '%s IS NULL', $self->expression($cond);
  }

  if (my $cond = $data->{"like"}) {
    return sprintf '%s %s %s', $self->expression($cond->[0]),
      $self->term('like'), $self->expression($cond->[1]);
  }

  if (my $cond = $data->{"lt"}) {
    return sprintf '%s < %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"lte"}) {
    return sprintf '%s <= %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"ne"}) {
    return sprintf '%s != %s', map $self->expression($_), @$cond;
  }

  if (my $cond = $data->{"not"}) {
    return sprintf 'NOT (%s)',
      (ref($cond) eq 'HASH')
        ? $self->expression($cond)
        : join(sprintf(' %s ', $self->term('and')), @{$self->criteria($cond)});
  }

  if (my $cond = $data->{"not-null"}) {
    return sprintf '%s IS NOT NULL', $self->expression($cond);
  }

  if (my $cond = $data->{"or"}) {
    return sprintf('(%s)',
      join(sprintf(' %s ', $self->term('or')), @{$self->criteria($cond)}));
  }

  if (my $cond = $data->{"regexp"}) {
    return sprintf '%s %s %s', $self->expression($cond->[0]),
      $self->term('regexp'), $self->expression($cond->[1]);
  }
}

method delete(HashRef $data) {
  my $sql = [];

  # delete
  push @$sql, $self->term(qw(delete from));

  # from
  push @$sql, $self->table($data->{from});

  # where
  if (my $where = $data->{where}) {
    push @$sql, $self->term('where'),
      join(sprintf(' %s ', $self->term('and')), @{$self->criteria($where)});
  }

  # returning (postgres)
  if (my $returning = $data->{returning}) {
    push @$sql, $self->term('returning'),
      sprintf('(%s)', join(', ', map $self->expression($_), @$returning));
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method database_create(HashRef $data) {
  my $sql = [];

  # create database
  push @$sql, $self->term(qw(create database)),
    ($data->{safe} ? $self->term(qw(if not exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method database_drop(HashRef $data) {
  my $sql = [];

  # drop database
  push @$sql, $self->term(qw(drop database)),
    ($data->{safe} ? $self->term(qw(if exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method execute() {
  if ($self->validator and not $self->validate) {
    die $self->validator->error;
  }

  return $self->process;
}

method expression(Any $data) {
  if (!ref $data) {
    return $self->value($data); # literal
  }

  if (UNIVERSAL::isa($data, 'SCALAR')) {
    if ($$data eq '1') {
      return $self->term('true');
    }
    if ($$data eq '0') {
      return $self->term('false');
    }
  }

  if (my $expr = $data->{"as"}) {
    my ($alias, $other) = @$expr;
    return sprintf '%s %s %s',
      $self->expression($other),
      $self->term('as'),
      $alias;
  }

  if (my $expr = $data->{"binary"}) {
    if ($expr->{plus}) {
      return sprintf '(%s + %s)',
        map $self->expression($_), @{$expr->{plus}};
    }
    if ($expr->{minus}) {
      return sprintf '(%s - %s)',
        map $self->expression($_), @{$expr->{minus}};
    }
    if ($expr->{multiply}) {
      return sprintf '(%s * %s)',
        map $self->expression($_), @{$expr->{multiply}};
    }
    if ($expr->{divide}) {
      return sprintf '(%s / %s)',
        map $self->expression($_), @{$expr->{divide}};
    }
    if ($expr->{modulo}) {
      return sprintf '(%s % %s)',
        map $self->expression($_), @{$expr->{modulo}};
    }
  }

  if ($data->{"binding"}) {
    return $self->binding($data->{"binding"});
  }

  if (my $expr = $data->{"case"}) {
    return sprintf(
      '%s %s %s %s %s',
      $self->term('case'),
      join(
        ' ',
        map {
          sprintf '%s %s %s %s', $self->term('when'),
            ($self->expression($$_{cond}) || $self->criterion($$_{cond})),
            $self->term('then'), $self->expression($$_{then});
        } @{$expr->{"when"}}
      ),
      $self->term('else'),
      $self->expression($expr->{"else"}),
      $self->term('end')
    );
  }

  if ($data->{"cast"}) {
    return sprintf(
      '%s(%s)',
      $self->term('cast'),
      join(
        sprintf(' %s ', $self->term('as')),
        map $self->expression($_),
        @{$data->{"cast"}}
      )
    );
  }

  if ($data->{"column"}) {
    return $self->name($data->{"alias"}, $data->{"column"});
  }

  if ($data->{"function"}) {
    my ($name, @args) = @{$data->{"function"}};
    return sprintf('%s(%s)',
      $name, join(', ', @args ? (map $self->expression($_), @args) : ''));
  }

  if (my $expr = $data->{"subquery"}) {
    $self->select($expr->{select});
    my $operation = $self->operations->pop;
    $self->{bindings} = $operation->bindings;
    return sprintf('(%s)', $operation->statement);
  }

  if (my $expr = $data->{"unary"}) {
    if ($expr->{"plus"}) {
      return sprintf '+%s', $self->expression($expr->{"plus"});
    }
    if ($expr->{"minus"}) {
      return sprintf '-%s', $self->expression($expr->{"minus"});
    }
  }

  if (my $expr = $data->{"verbatim"}) {
    my @verbatim = @{$data->{"verbatim"}};
    return join(' ', $verbatim[0],
      join(', ', map $self->expression($_), @verbatim[1..$#verbatim]));
  }
}

method join_option(Maybe[Str] $name) {
  if (!$name) {
    return $self->term(qw(join));
  }
  if (lc($name) eq "left-join") {
    return $self->term(qw(left join));
  }
  elsif (lc($name) eq "right-join") {
    return $self->term(qw(right join));
  }
  elsif (lc($name) eq "full-join") {
    return $self->term(qw(full join));
  }
  elsif (lc($name) eq "inner-join") {
    return $self->term(qw(inner join));
  }
  else {
    return $self->term(qw(join));
  }
}

method name(Any @args) {

  return join '.', map { /\W/ ? $_ : $self->wrap($_) } grep {defined} @args;
}

method operation(Str $statement) {
  $self->operations->push(
    my $operation = SQL::Engine::Operation->new(
      bindings => delete $self->{bindings} || {},
      statement => $statement,
    )
  );

  return $operation;
}

method process(HashRef $schema = $self->schema) {
  if ($schema->{"select"}) {
    $self->select($schema->{"select"});

    return $self;
  }

  if ($schema->{"insert"}) {
    $self->insert($schema->{"insert"});

    return $self;
  }

  if ($schema->{"update"}) {
    $self->update($schema->{"update"});

    return $self;
  }

  if ($schema->{"delete"}) {
    $self->delete($schema->{"delete"});

    return $self;
  }

  if ($schema->{"column-change"}) {
    $self->column_change($schema->{"column-change"});

    return $self;
  }

  if ($schema->{"column-create"}) {
    $self->column_create($schema->{"column-create"});

    return $self;
  }

  if ($schema->{"column-drop"}) {
    $self->column_drop($schema->{"column-drop"});

    return $self;
  }

  if ($schema->{"column-rename"}) {
    $self->column_rename($schema->{"column-rename"});

    return $self;
  }

  if ($schema->{"constraint-create"}) {
    $self->constraint_create($schema->{"constraint-create"});

    return $self;
  }

  if ($schema->{"constraint-drop"}) {
    $self->constraint_drop($schema->{"constraint-drop"});

    return $self;
  }

  if ($schema->{"database-create"}) {
    $self->database_create($schema->{"database-create"});

    return $self;
  }

  if ($schema->{"database-drop"}) {
    $self->database_drop($schema->{"database-drop"});

    return $self;
  }

  if ($schema->{"index-create"}) {
    $self->index_create($schema->{"index-create"});

    return $self;
  }

  if ($schema->{"index-drop"}) {
    $self->index_drop($schema->{"index-drop"});

    return $self;
  }

  if ($schema->{"schema-create"}) {
    $self->schema_create($schema->{"schema-create"});

    return $self;
  }

  if ($schema->{"schema-drop"}) {
    $self->schema_drop($schema->{"schema-drop"});

    return $self;
  }

  if ($schema->{"schema-rename"}) {
    $self->schema_rename($schema->{"schema-rename"});

    return $self;
  }

  if ($schema->{"table-create"}) {
    $self->table_create($schema->{"table-create"});

    return $self;
  }

  if ($schema->{"table-drop"}) {
    $self->table_drop($schema->{"table-drop"});

    return $self;
  }

  if ($schema->{"transaction"}) {
    $self->transaction($schema->{"transaction"});

    return $self;
  }

  if ($schema->{"table-rename"}) {
    $self->table_rename($schema->{"table-rename"});

    return $self;
  }

  if ($schema->{"view-create"}) {
    $self->view_create($schema->{"view-create"});

    return $self;
  }

  if ($schema->{"view-drop"}) {
    $self->view_drop($schema->{"view-drop"});

    return $self;
  }

  if ($schema->{"union"}) {
    $self->union($schema->{"union"});

    return $self;
  }

  return $self;
}

method index_create(HashRef $data) {
  my $sql = [];

  # create
  push @$sql, $self->term('create');

  # unique
  push @$sql, $self->term('unique') if $data->{unique};

  # index
  push @$sql, $self->term('index');

  # safe
  push @$sql, $self->term(qw(if not exists)) if $data->{safe};

  # index name
  push @$sql, $self->wrap($self->index_name($data));

  # on table
  push @$sql, $self->term('on'), $self->table($data->{for});

  # columns
  push @$sql, sprintf('(%s)',
    join(', ', map $self->name($$_{alias}, $$_{column}), @{$data->{columns}}));

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method index_drop(HashRef $data) {
  my $sql = [];

  # drop
  push @$sql, $self->term('drop');

  # index
  push @$sql, $self->term('index');

  # safe
  push @$sql, $self->term(qw(if exists)) if $data->{safe};

  # index name
  push @$sql, $self->wrap($self->index_name($data));

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method index_name(HashRef $data) {
  return $data->{name} || join('_',
    ($data->{unique} ? 'unique' : 'index'),
    grep {defined} $data->{for}{schema}, $data->{for}{table},
      map $$_{column}, @{$data->{columns}}
  );
}

method insert(HashRef $data) {
  my $sql = [];

  # insert
  push @$sql, $self->term('insert');

  # into
  push @$sql, $self->term('into'), $self->table($data->{into});

  # columns
  if (my $columns = $data->{columns}) {
    push @$sql,
      sprintf('(%s)', join(', ', map $self->expression($_), @$columns));
  }

  # values
  if (my $values = $data->{values}) {
    push @$sql,
      sprintf('%s (%s)',
      $self->term('values'),
      join(', ', map $self->expression($$_{value}), @$values));
  }

  # query
  if (my $query = $data->{query}) {
    $self->select($query->{select});
    my $operation = $self->operations->pop;
    $self->{bindings} = $operation->bindings;
    push @$sql, $operation->statement;
  }

  # default
  if ($data->{default} && !$data->{values} && !$data->{values}) {
    push @$sql, $self->term('default'), $self->term('values');
  }

  # returning (postgres)
  if (my $returning = $data->{returning}) {
    push @$sql, $self->term('returning'),
      sprintf('(%s)', join(', ', map $self->expression($_), @$returning));
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method schema_create(HashRef $data) {
  my $sql = [];

  # create schema
  push @$sql, $self->term(qw(create schema)),
    ($data->{safe} ? $self->term(qw(if not exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method schema_drop(HashRef $data) {
  my $sql = [];

  # drop schema
  push @$sql, $self->term(qw(drop schema)),
    ($data->{safe} ? $self->term(qw(if exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method schema_rename(HashRef $data) {
  my $sql = [];

  # rename schema
  push @$sql, $self->term(qw(alter schema)),
    $self->name($data->{name}{old}),
    $self->term(qw(rename to)),
    $self->name($data->{name}{new});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method select(HashRef $data) {
  my $sql = [];

  # select
  push @$sql, $self->term('select');

  # columns
  if (my $columns = $data->{columns}) {
    push @$sql, join(', ', map $self->expression($_), @$columns);
  }

  # into (mssql)
  if (my $into = $data->{into}) {
    push @$sql, $self->term('into'), $self->name($into);
  }

  # from
  push @$sql, $self->term('from'),
    ref($data->{from}) eq 'ARRAY'
    ? join(', ', map $self->table($_), @{$data->{from}})
    : $self->table($data->{from});

  # joins
  if (my $joins = $data->{joins}) {
    for my $join (@$joins) {
      push @$sql, $self->join_option($join->{type}), $self->table($join->{with});
      push @$sql, $self->term('on'),
        join(
        sprintf(' %s ', $self->term('and')),
        @{$self->criteria($join->{having})}
        );
    }
  }

  # where
  if (my $where = $data->{where}) {
    push @$sql, $self->term('where'),
      join(sprintf(' %s ', $self->term('and')), @{$self->criteria($where)});
  }

  # group-by
  if (my $group_by = $data->{"group-by"}) {
    push @$sql, $self->term(qw(group by));
    push @$sql, join ', ', map $self->expression($_), @$group_by;

    # having
    if (my $having = $data->{"having"}) {
      push @$sql, $self->term('having'),
        join(sprintf(' %s ', $self->term('and')), @{$self->criteria($having)});
    }
  }

  # order-by
  if (my $orders = $data->{"order-by"}) {
    my @orders;
    push @$sql, $self->term(qw(order by));
    for my $order (@$orders) {
      if ($order->{sort}
        && ($order->{sort} eq 'asc' || $order->{sort} eq 'ascending'))
      {
        push @orders, sprintf '%s ASC',
          $self->name($order->{"alias"}, $order->{"column"});
      }
      elsif ($order->{sort}
        && ($order->{sort} eq 'desc' || $order->{sort} eq 'descending'))
      {
        push @orders, sprintf '%s DESC',
          $self->name($order->{"alias"}, $order->{"column"});
      }
      else {
        push @orders, $self->name($order->{"alias"}, $order->{"column"});
      }
    }
    push @$sql, join ', ', @orders;
  }

  # rows
  if (my $rows = $data->{rows}) {
    if ($rows->{limit} && $rows->{offset}) {
      push @$sql, sprintf '%s %d %s %d', $self->term('limit'), $rows->{limit},
        $self->term('offset'), $rows->{offset};
    }
    if ($rows->{limit} && !$rows->{offset}) {
      push @$sql, sprintf '%s %d', $self->term('limit'), $rows->{limit};
    }
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method table(HashRef $data) {
  my $name;

  my $table  = $data->{table};
  my $schema = $data->{schema};
  my $alias  = $data->{alias};

  $name = $self->name($schema, $table);
  $name = join ' ', $name, $self->wrap($alias) if $alias;

  return $name;
}

method table_create(HashRef $data) {
  my $sql = [];

  # create
  push @$sql, $self->term('create');

  # temporary
  if ($data->{temp}) {
    push @$sql, $self->term('temporary');
  }

  # table
  push @$sql, $self->term('table'),
    ($data->{safe} ? $self->term(qw(if not exists)) : ()),
    $self->name($data->{name});

  # body
  my $body = [];

  # columns
  if (my $columns = $data->{columns}) {
    push @$body, map $self->column_specification($_), @$columns;
  }

  # constraints
  if (my $constraints = $data->{constraints}) {
    # unique
    for my $constraint (grep {$_->{unique}} @{$constraints}) {
      if (my $unique = $constraint->{unique}) {
        my $name = $self->index_name({
          for => $data->{for},
          name => $unique->{name},
          columns => [map +{column => $_}, @{$unique->{columns}}],
          unique => 1,
        });
        push @$body, join ' ', $self->term('constraint'), $name,
          $self->term('unique'), sprintf '(%s)', join ', ',
          map $self->name($_), @{$unique->{columns}};
      }
    }
    # foreign
    for my $constraint (grep {$_->{foreign}} @{$constraints}) {
      if (my $foreign = $constraint->{foreign}) {
        my $name = $self->constraint_name({
          source => {
            table => $data->{name},
            column => $foreign->{column}
          },
          target => $foreign->{reference},
          name => $foreign->{name}
        });
        push @$body, join ' ', $self->term('constraint'), $name,
          $self->term(qw(foreign key)),
          sprintf('(%s)', $self->name($foreign->{column})),
          $self->term(qw(references)),
          sprintf('%s (%s)',
          $self->table($foreign->{reference}),
          $self->name($foreign->{reference}{column})),
          (
          $foreign->{on}{delete}
          ? (
            $self->term(qw(on delete)),
            $self->constraint_option($foreign->{on}{delete})
            )
          : ()
          ),
          (
          $foreign->{on}{update}
          ? (
            $self->term(qw(on update)),
            $self->constraint_option($foreign->{on}{update})
            )
          : ()
          );
      }
    }
  }

  # definition
  if (@$body) {
    push @$sql, sprintf('(%s)', join ', ', @$body);
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

method table_drop(HashRef $data) {
  my $sql = [];

  # drop table
  push @$sql, $self->term(qw(drop table)),
    ($data->{safe} ? $self->term(qw(if exists)) : ()),
    $self->name($data->{name});

  # with condition
  if (my $condition = $data->{condition}) {
    push @$sql, $self->term($data->{condition});
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method table_rename(HashRef $data) {
  my $sql = [];

  # rename table
  push @$sql, $self->term(qw(alter table)),
    $self->name($data->{name}{old}),
    $self->term(qw(rename to)),
    $self->name($data->{name}{new});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method term(Str @args) {
  my $method = join '_', 'term', map lc, map {split /\s/} @args;

  if ($self->can($method)) {
    return $self->$method;
  }
  else {
    return join ' ', map uc, @args;
  }
}

method transaction(HashRef $data) {
  $self->operation($self->term('begin', 'transaction'));
  $self->process($_) for @{$data->{queries}};
  $self->operation($self->term('commit'));

  return $self;
}

method type(HashRef $data) {
  if ($data->{type} eq 'binary') {
    return $self->type_binary($data);
  }

  if ($data->{type} eq 'boolean') {
    return $self->type_boolean($data);
  }

  if ($data->{type} eq 'char') {
    return $self->type_char($data);
  }

  if ($data->{type} eq 'date') {
    return $self->type_date($data);
  }

  if ($data->{type} eq 'datetime') {
    return $self->type_datetime($data);
  }

  if ($data->{type} eq 'datetime-wtz') {
    return $self->type_datetime_wtz($data);
  }

  if ($data->{type} eq 'decimal') {
    return $self->type_decimal($data);
  }

  if ($data->{type} eq 'double') {
    return $self->type_double($data);
  }

  if ($data->{type} eq 'enum') {
    return $self->type_enum($data);
  }

  if ($data->{type} eq 'float') {
    return $self->type_float($data);
  }

  if ($data->{type} eq 'integer') {
    return $self->type_integer($data);
  }

  if ($data->{type} eq 'integer-big') {
    return $self->type_integer_big($data);
  }

  if ($data->{type} eq 'integer-big-unsigned') {
    return $self->type_integer_big_unsigned($data);
  }

  if ($data->{type} eq 'integer-medium') {
    return $self->type_integer_medium($data);
  }

  if ($data->{type} eq 'integer-medium-unsigned') {
    return $self->type_integer_medium_unsigned($data);
  }

  if ($data->{type} eq 'integer-small') {
    return $self->type_integer_small($data);
  }

  if ($data->{type} eq 'integer-small-unsigned') {
    return $self->type_integer_small_unsigned($data);
  }

  if ($data->{type} eq 'integer-tiny') {
    return $self->type_integer_tiny($data);
  }

  if ($data->{type} eq 'integer-tiny-unsigned') {
    return $self->type_integer_tiny_unsigned($data);
  }

  if ($data->{type} eq 'integer-unsigned') {
    return $self->type_integer_unsigned($data);
  }

  if ($data->{type} eq 'json') {
    return $self->type_json($data);
  }

  if ($data->{type} eq 'number') {
    return $self->type_number($data);
  }

  if ($data->{type} eq 'string') {
    return $self->type_string($data);
  }

  if ($data->{type} eq 'text') {
    return $self->type_text($data);
  }

  if ($data->{type} eq 'text-long') {
    return $self->type_text_long($data);
  }

  if ($data->{type} eq 'text-medium') {
    return $self->type_text_medium($data);
  }

  if ($data->{type} eq 'time') {
    return $self->type_time($data);
  }

  if ($data->{type} eq 'time-wtz') {
    return $self->type_time_wtz($data);
  }

  if ($data->{type} eq 'timestamp') {
    return $self->type_timestamp($data);
  }

  if ($data->{type} eq 'timestamp-wtz') {
    return $self->type_timestamp_wtz($data);
  }

  if ($data->{type} eq 'uuid') {
    return $self->type_uuid($data);
  }

  return $data->{type};
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

  return 'integer';
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

method update(HashRef $data) {
  my $sql = [];

  # update
  push @$sql, $self->term('update');

  # for
  push @$sql, $self->table($data->{for});

  # columns
  if (my $columns = $data->{columns}) {
    push @$sql, $self->term('set');
    push @$sql, join(
      ', ',
      map {
        sprintf('%s = %s',
          $self->name($$_{alias}, $$_{column}),
          $self->expression($$_{value}))
      } @$columns
    );
  }

  # where
  if (my $where = $data->{where}) {
    push @$sql, $self->term('where'),
      join(sprintf(' %s ', $self->term('and')), @{$self->criteria($where)});
  }

  # returning (postgres)
  if (my $returning = $data->{returning}) {
    push @$sql, $self->term('returning'),
      sprintf('(%s)', join(', ', map $self->expression($_), @$returning));
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method validate() {

  return $self->validator->validate($self->schema);
}

method value(Any $value) {

  return !defined $value ? $self->term('null') : (
    Scalar::Util::looks_like_number($value) ? $value : do {
      $value =~ s/\'/\\'/g;
      "'$value'"
    }
  );
}

method view_create(HashRef $data) {
  my $sql = [];

  # create
  push @$sql, $self->term('create');

  # temporary
  if ($data->{temp}) {
    push @$sql, $self->term('temporary');
  }

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

method view_drop(HashRef $data) {
  my $sql = [];

  # drop view
  push @$sql, $self->term(qw(drop view)),
    ($data->{safe} ? $self->term(qw(if exists)) : ()),
    $self->name($data->{name});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method union(HashRef $data) {
  my $sql = [];

  # union
  my $type = $self->term('union');

  # union type
  if ($data->{type}) {
    $type = join ' ', $type, $self->term($data->{type});
  }

  # union queries
  for my $query (@{$data->{queries}}) {
    $self->process($query);
    my $operation = $self->operations->pop;
    $self->{bindings} = $operation->bindings;
    push @$sql, sprintf('(%s)', $operation->statement);
  }

  # sql statement
  my $result = join " $type ", @$sql;

  return $self->operation($result);
}

method wrap(Str $name) {

  return qq("$name");
}

1;
