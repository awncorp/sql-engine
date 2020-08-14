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
    push @$sql, $self->term(qw(alter column));

    # column name
    push @$sql, $self->name($data->{column}{name});

    # column type
    push @$sql, $def->{type};

    # column (set | drop) not null
    push @$sql,
      (exists $data->{column}{nullable})
      ? (
          $data->{column}{nullable}
          ? $self->term(qw(null))
          : $self->term(qw(not null))
        )
      : $self->term(qw(null));

    # sql statement
    join ' ', @$sql
  });

  # drop any column default
  $self->operation(do {
    my $sql = [];

    my $tsql = q{
      DECLARE @schema_name nvarchar(256);
      DECLARE @table_name nvarchar(256);
      DECLARE @col_name nvarchar(256);
      DECLARE @Command  nvarchar(1000);

      SET @schema_name = DB_NAME();
      SET @table_name = N'{TABLE_NAME}';
      SET @col_name = N'{COLUMN_NAME}';

      SELECT @Command = 'ALTER TABLE ' + @schema_name + '.[' + @table_name + '] DROP CONSTRAINT ' + d.name
       FROM sys.tables t
        JOIN sys.default_constraints d on d.parent_object_id = t.object_id
        JOIN sys.columns c on c.object_id = t.object_id and c.column_id = d.parent_column_id
       WHERE t.name = @table_name
        AND t.schema_id = schema_id(@schema_name)
        AND c.name = @col_name;

      EXECUTE (@Command)
    };

    my $table_name = $self->table($data->{"for"});
    my $column_name = $self->name($data->{column}{name});

    $tsql =~ s/\{TABLE_NAME\}/$table_name/;
    $tsql =~ s/\{COLUMN_NAME\}/$column_name/;
    $tsql =~ s/\s+/ /g;
    $tsql =~ s/\n+//g;

    push @$sql, $tsql;

    # sql statement
    join ' ', @$sql
  });

  # column set default
  if ($data->{column}{default}) {
    $self->operation(do {
      my $sql = [];

      # alter table
      push @$sql, $self->term(qw(alter table));

      # safe
      push @$sql, $self->term(qw(if exists)) if $data->{safe};

      # for
      push @$sql, $self->table($data->{for});

      # default constraint name
      push @$sql, $self->term(qw(add constraint)),
        join '_', 'DF', $data->{column}{name};

      # default
      push @$sql, $def->{default};

      # column name
      push @$sql, $self->term(qw(for)), $self->name($data->{column}{name});

      # sql statement
      join ' ', @$sql
    });
  }

  $self->operation($self->term('commit'));

  return $self;
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
  push @$sql, $self->term(qw(add));

  # column specification
  push @$sql, $self->column_specification($data->{column});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method column_definition(HashRef $data) {
  my $def = $self->next::method($data);

  if (exists $data->{default}) {
    $def->{default} = join ' ', $self->term('default'),
      sprintf '(%s)', $self->expression($data->{default});
  }

  if ($data->{increment}) {
    $def->{increment} = $self->term('identity');
  }

  return $def;
}

method column_rename(HashRef $data) {
  my $sql = [];

  # table name
  my $table = join '.', $self->table($data->{"for"}), $self->name($data->{name}{old});

  # rename column
  push @$sql, $self->term(qw(exec)),
    'sp_rename',
    join ', ',
    $self->value($table),
    $self->value($self->name($data->{name}{new})),
    $self->value(uc('column'));

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

  # table
  push @$sql, $self->term('on'), $self->table($data->{for});

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
      push @$sql, $self->term('join'), $self->table($join->{with});
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
      push @$sql, sprintf '%s %d %s',
        $self->term('offset'),
        $rows->{offset},
        $self->term(qw(rows));
      push @$sql, sprintf '%s %d %s',
        $self->term(qw(fetch next)),
        $rows->{limit},
        $self->term(qw(rows only));
    }
    if ($rows->{limit} && !$rows->{offset}) {
      push @$sql, sprintf '%s %d %s',
        $self->term('offset'),
        0,
        $self->term(qw(rows));
      push @$sql, sprintf '%s %d %s',
        $self->term(qw(fetch next)),
        $rows->{limit},
        $self->term(qw(rows only));
    }
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method table_create(HashRef $data) {
  my $sql = [];

  # create
  push @$sql, $self->term('create');

  # temporary
  my $name;
  if ($data->{temp}) {
    $name = "#".$data->{name};
  }
  else {
    $name = $data->{name};
  }

  # table
  push @$sql, $self->term('table'),
    ($data->{safe} ? $self->term(qw(if not exists)) : ()),
    $self->name($name);

  # columns
  if (my $columns = $data->{columns}) {
    push @$sql, sprintf('(%s)', join ', ',
      map $self->column_specification($_), @$columns);
  }

  # query
  if (my $query = $data->{query}) {
    $sql = [];
    $self->select({%{$query->{select}}, into => $name});
    my $operation = $self->operations->pop;
    $self->{bindings} = $operation->bindings;
    push @$sql, $operation->statement;
  }

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method table_rename(HashRef $data) {
  my $sql = [];

  # rename table
  push @$sql, $self->term(qw(exec)), 'sp_rename',
    join ', ', $self->name($data->{name}{old}), $self->name($data->{name}{new});

  # sql statement
  my $result = join ' ', @$sql;

  return $self->operation($result);
}

method transaction(HashRef $data) {
  my @mode;
  if ($data->{mode}) {
    @mode = map $self->term($_), @{$data->{mode}};
  }
  if (@mode) {
    $self->operation($self->term(qw(set transaction isolation level), @mode));
  }
  $self->operation($self->term('begin', 'transaction'));
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
