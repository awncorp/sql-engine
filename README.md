# NAME

SQL::Engine - SQL Generation

# ABSTRACT

SQL Generation for Perl 5

# SYNOPSIS

    use SQL::Engine;

    my $sql = SQL::Engine->new;

    $sql->insert(
      into => {
        table => 'users'
      },
      columns => [
        {
          column => 'id'
        },
        {
          column => 'name'
        }
      ],
      values => [
        {
          value => undef
        },
        {
          value => {
            binding => 'name'
          }
        },
      ]
    );

    # then, e.g.
    #
    # my $dbh = DBI->connect;
    #
    # for my $operation ($sql->operations->list) {
    #   my $statement = $operation->statement;
    #   my @bindings  = $operation->parameters({ name => 'Rob Zombie' });
    #
    #   my $sth = $dbh->prepate($statement);
    #
    #   $sth->execute(@bindings);
    # }
    #
    # $dbh->disconnect;

# DESCRIPTION

This package provides an interface and builders which generate SQL statements,
by default using a standard SQL syntax or vendor-specific syntax if supported
and provided to the constructor using the _"grammar"_ property. This package
does not require a database connection, by design, which gives users complete
control over how connections and statement handles are managed.

# LIBRARIES

This package uses type constraints from:

[Types::Standard](https://metacpan.org/pod/Types%3A%3AStandard)

# SCENARIOS

This package supports the following scenarios:

## validation

    use SQL::Engine;

    my $sql = SQL::Engine->new(
      validator => undef
    );

    # faster, no-validation

    $sql->select(
      from => {
        table => 'users'
      },
      columns => [
        {
          column => '*'
        }
      ]
    );

This package supports automatic validation of operations using
[SQL::Validator](https://metacpan.org/pod/SQL%3A%3AValidator) which can be passed to the constructor as the value of the
_"validator"_ property. This object will be generated if not provided.
Alternatively, automated validation can be disabled by passing the
_"undefined"_ value to the _"validator"_ property on object construction.
Doing so enhances the performance of SQL generation at the cost of not
verifying that the instructions provided are correct.

# ATTRIBUTES

This package has the following attributes:

## grammar

    grammar(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

## operations

    operations(InstanceOf["SQL::Engine::Collection"])

This attribute is read-only, accepts `(InstanceOf["SQL::Engine::Collection"])` values, and is optional.

## validator

    validator(Maybe[InstanceOf["SQL::Validator"]])

This attribute is read-only, accepts `(Maybe[InstanceOf["SQL::Validator"]])` values, and is optional.

# METHODS

This package implements the following methods:

## column\_change

    column_change(Any %args) : Object

The column\_change method produces SQL operations which changes a table column
definition. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ColumnChange](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AColumnChange).

- column\_change example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->column_change(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            nullable => 1
          }
        );

## column\_create

    column_create(Any %args) : Object

The column\_create method produces SQL operations which create a new table
column. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ColumnCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AColumnCreate).

- column\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->column_create(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime'
          }
        );

## column\_drop

    column_drop(Any %args) : Object

The column\_drop method produces SQL operations which removes an existing table
column. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ColumnDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AColumnDrop).

- column\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->column_drop(
          table => 'users',
          column => 'accessed'
        );

## column\_rename

    column_rename(Any %args) : Object

The column\_rename method produces SQL operations which renames an existing
table column. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ColumnRename](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AColumnRename).

- column\_rename example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->column_rename(
          for => {
            table => 'users'
          },
          name => {
            old => 'accessed',
            new => 'accessed_at'
          }
        );

## constraint\_create

    constraint_create(Any %args) : Object

The constraint\_create method produces SQL operations which creates a new table
constraint. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ConstraintCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AConstraintCreate).

- constraint\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->constraint_create(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          }
        );

## constraint\_drop

    constraint_drop(Any %args) : Object

The constraint\_drop method produces SQL operations which removes an existing
table constraint. The arguments expected are the constructor arguments accepted
by [SQL::Engine::Builder::ConstraintDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AConstraintDrop).

- constraint\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->constraint_drop(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          }
        );

## database\_create

    database_create(Any %args) : Object

The database\_create method produces SQL operations which creates a new
database. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::DatabaseCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ADatabaseCreate).

- database\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->database_create(
          name => 'todoapp'
        );

## database\_drop

    database_drop(Any %args) : Object

The database\_drop method produces SQL operations which removes an existing
database. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::DatabaseDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ADatabaseDrop).

- database\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->database_drop(
          name => 'todoapp'
        );

## delete

    delete(Any %args) : Object

The delete method produces SQL operations which deletes rows from a table. The
arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::Delete](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ADelete).

- delete example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->delete(
          from => {
            table => 'tasklists'
          }
        );

## index\_create

    index_create(Any %args) : Object

The index\_create method produces SQL operations which creates a new table
index. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::IndexCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AIndexCreate).

- index\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ]
        );

## index\_drop

    index_drop(Any %args) : Object

The index\_drop method produces SQL operations which removes an existing table
index. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::IndexDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AIndexDrop).

- index\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->index_drop(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ]
        );

## insert

    insert(Any %args) : Object

The insert method produces SQL operations which inserts rows into a table. The
arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::Insert](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AInsert).

- insert example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->insert(
          into => {
            table => 'users'
          },
          values => [
            {
              value => undef
            },
            {
              value => 'Rob Zombie'
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            }
          ]
        );

## schema\_create

    schema_create(Any %args) : Object

The schema\_create method produces SQL operations which creates a new schema.
The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::SchemaCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ASchemaCreate).

- schema\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->schema_create(
          name => 'private',
        );

## schema\_drop

    schema_drop(Any %args) : Object

The schema\_drop method produces SQL operations which removes an existing
schema. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::SchemaDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ASchemaDrop).

- schema\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->schema_drop(
          name => 'private',
        );

## schema\_rename

    schema_rename(Any %args) : Object

The schema\_rename method produces SQL operations which renames an existing
schema. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::SchemaRename](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ASchemaRename).

- schema\_rename example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->schema_rename(
          name => {
            old => 'private',
            new => 'restricted'
          }
        );

## select

    select(Any %args) : Object

The select method produces SQL operations which select rows from a table. The
arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::Select](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ASelect).

- select example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->select(
          from => {
            table => 'people'
          },
          columns => [
            { column => 'name' }
          ]
        );

## table\_create

    table_create(Any %args) : Object

The table\_create method produces SQL operations which creates a new table. The
arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::TableCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ATableCreate).

- table\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->table_create(
          name => 'users',
          columns => [
            {
              name => 'id',
              type => 'integer',
              primary => 1
            }
          ]
        );

## table\_drop

    table_drop(Any %args) : Object

The table\_drop method produces SQL operations which removes an existing table.
The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::TableDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ATableDrop).

- table\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->table_drop(
          name => 'people'
        );

## table\_rename

    table_rename(Any %args) : Object

The table\_rename method produces SQL operations which renames an existing
table. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::TableRename](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ATableRename).

- table\_rename example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->table_rename(
          name => {
            old => 'peoples',
            new => 'people'
          }
        );

## transaction

    transaction(Any %args) : Object

The transaction method produces SQL operations which represents an atomic
database operation. The arguments expected are the constructor arguments
accepted by [SQL::Engine::Builder::Transaction](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3ATransaction).

- transaction example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->transaction(
          queries => [
            {
              'table-create' => {
                name => 'users',
                columns => [
                  {
                    name => 'id',
                    type => 'integer',
                    primary => 1
                  }
                ]
              }
            }
          ]
        );

## union

    union(Any %args) : Object

The union method produces SQL operations which returns a results from two or
more select queries. The arguments expected are the constructor arguments
accepted by [SQL::Engine::Builder::Union](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AUnion).

- union example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->union(
          queries => [
            {
              select => {
                from => {
                  table => 'customers',
                },
                columns => [
                  {
                    column => 'name',
                  }
                ]
              }
            },
            {
              select => {
                from => {
                  table => 'employees',
                },
                columns => [
                  {
                    column => 'name',
                  }
                ]
              }
            }
          ]
        );

## update

    update(Any %args) : Object

The update method produces SQL operations which update rows in a table. The
arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::Update](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AUpdate).

- update example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->update(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'updated',
              value => { function => ['now'] }
            }
          ]
        );

## view\_create

    view_create(Any %args) : Object

The view\_create method produces SQL operations which creates a new table view.
The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ViewCreate](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AViewCreate).

- view\_create example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->view_create(
          name => 'active_users',
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => '*'
                }
              ],
              where => [
                {
                  'not-null' => {
                    column => 'deleted'
                  }
                }
              ]
            }
          }
        );

## view\_drop

    view_drop(Any %args) : Object

The view\_drop method produces SQL operations which removes an existing table
view. The arguments expected are the constructor arguments accepted by
[SQL::Engine::Builder::ViewDrop](https://metacpan.org/pod/SQL%3A%3AEngine%3A%3ABuilder%3A%3AViewDrop).

- view\_drop example #1

        # given: synopsis

        $sql->operations->clear;

        $sql->view_drop(
          name => 'active_users'
        );

# EXAMPLES

This distribution supports generating SQL statements using standard syntax or
using database-specific syntax if a _grammar_ is specified. The following is a
collection of examples covering the most common operations (using PostgreSQL
syntax):

## setup

    use SQL::Engine;

    my $sql = SQL::Engine->new(
      grammar => 'postgres'
    );

    $sql->select(
      from => {
        table => 'people'
      },
      columns => [
        { column => 'name' }
      ]
    );

    $sql->operations->first->statement;

    # SELECT "name" FROM "people"

## select

- select example #1

        $sql->select(
          from => {
            table => 'users'
          },
          columns => [
            {
              column => '*'
            }
          ]
        );

- select example #1 output

        # SELECT * FROM "users"

- select example #2

        $sql->select(
          from => {
            table => 'users'
          },
          columns => [
            {
              column => 'id'
            },
            {
              column => 'name'
            }
          ]
        );

- select example #2 output

        # SELECT "id", "name" FROM "users"

- select example #3

        $sql->select(
          from => {
            table => 'users'
          },
          columns => [
            {
              column => '*'
            }
          ],
          where => [
            {
              eq => [{column => 'id'}, {binding => 'id'}]
            }
          ]
        );

- select example #3 output

        # SELECT * FROM "users" WHERE "id" = ?

- select example #4

        $sql->select(
          from => {
            table => 'users',
            alias => 'u'
          },
          columns => [
            {
              column => '*',
              alias => 'u'
            }
          ],
          joins => [
            {
              with => {
                table => 'tasklists',
                alias => 't'
              },
              having => [
                {
                  eq => [
                    {
                      column => 'id',
                      alias => 'u'
                    },
                    {
                      column => 'user_id',
                      alias => 't'
                    }
                  ]
                }
              ]
            }
          ],
          where => [
            {
              eq => [
                {
                  column => 'id',
                  alias => 'u'
                },
                {
                  binding => 'id'
                }
              ]
            }
          ]
        );

- select example #4 output

        # SELECT "u".* FROM "users" "u"
        # JOIN "tasklists" "t" ON "u"."id" = "t"."user_id" WHERE "u"."id" = ?

- select example #5

        $sql->select(
          from => {
            table => 'tasklists'
          },
          columns => [
            {
              function => ['count', { column => 'user_id' }]
            }
          ],
          group_by => [
            {
              column => 'user_id'
            }
          ]
        );

- select example #5 output

        # SELECT count("user_id") FROM "tasklists" GROUP BY "user_id"

- select example #6

        $sql->select(
          from => {
            table => 'tasklists'
          },
          columns => [
            {
              function => ['count', { column => 'user_id' }]
            }
          ],
          group_by => [
            {
              column => 'user_id'
            }
          ],
          having => [
            {
              gt => [
                {
                  function => ['count', { column => 'user_id' }]
                },
                1
              ]
            }
          ]
        );

- select example #6 output

        # SELECT count("user_id") FROM "tasklists" GROUP BY "user_id" HAVING
        # count("user_id") > 1

- select example #7

        $sql->select(
          from => {
            table => 'tasklists'
          },
          columns => [
            {
              column => '*'
            }
          ],
          order_by => [
            {
              column => 'user_id'
            }
          ]
        );

- select example #7 output

        # SELECT * FROM "tasklists" ORDER BY "user_id"

- select example #8

        $sql->select(
          from => {
            table => 'tasklists'
          },
          columns => [
            {
              column => '*'
            }
          ],
          order_by => [
            {
              column => 'user_id'
            },
            {
              column => 'id',
              sort => 'desc'
            }
          ]
        );

- select example #8 output

        # SELECT * FROM "tasklists" ORDER BY "user_id", "id" DESC

- select example #9

        $sql->select(
          from => {
            table => 'tasks'
          },
          columns => [
            {
              column => '*'
            }
          ],
          rows => {
            limit => 5
          }
        );

- select example #9 output

        # SELECT * FROM "tasks" LIMIT 5

- select example #10

        $sql->select(
          from => {
            table => 'tasks'
          },
          columns => [
            {
              column => '*'
            }
          ],
          rows => {
            limit => 5,
            offset => 1
          }
        );

- select example #10 output

        # SELECT * FROM "tasks" LIMIT 5, OFFSET 1

- select example #11

        $sql->select(
          from => [
            {
              table => 'tasklists',
              alias => 't1'
            },
            {
              table => 'tasks',
              alias => 't2'
            }
          ],
          columns => [
            {
              column => '*',
              alias => 't1'
            },
            {
              column => '*',
              alias => 't1'
            }
          ],
          where => [
            {
              eq => [
                {
                  column => 'tasklist_id',
                  alias => 't2'
                },
                {
                  column => 'id',
                  alias => 't1'
                }
              ]
            }
          ]
        );

- select example #11 output

        # SELECT "t1".*, "t1".* FROM "tasklists" "t1", "tasks" "t2"
        # WHERE "t2"."tasklist_id" = "t1"."id"

## insert

- insert example #1

        $sql->insert(
          into => {
            table => 'users'
          },
          values => [
            {
              value => undef
            },
            {
              value => 'Rob Zombie'
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            }
          ]
        );

- insert example #1 output

        # INSERT INTO "users" VALUES (NULL, 'Rob Zombie', now(), now(), now())

- insert example #2

        $sql->insert(
          into => {
            table => 'users'
          },
          columns => [
            {
              column => 'id'
            },
            {
              column => 'name'
            },
            {
              column => 'created'
            },
            {
              column => 'updated'
            },
            {
              column => 'deleted'
            }
          ],
          values => [
            {
              value => undef
            },
            {
              value => 'Rob Zombie'
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            },
            {
              value => {
                function => ['now']
              }
            }
          ]
        );

- insert example #2 output

        # INSERT INTO "users" ("id", "name", "created", "updated", "deleted")
        # VALUES (NULL, 'Rob Zombie', now(), now(), now())

- insert example #3

        $sql->insert(
          into => {
            table => 'users'
          },
          default => 1
        );

- insert example #3 output

        # INSERT INTO "users" DEFAULT VALUES

- insert example #4

        $sql->insert(
          into => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            },
            {
              column => 'user_id'
            }
          ],
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => 'name'
                },
                {
                  column => 'id'
                }
              ]
            }
          }
        );

- insert example #4 output

        # INSERT INTO "users" ("name", "user_id") SELECT "name", "id" FROM "users"

- insert example #5

        $sql->insert(
          into => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            },
            {
              column => 'user_id'
            }
          ],
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => 'name'
                },
                {
                  column => 'id'
                }
              ],
              where => [
                {
                  'not-null' => {
                    column => 'deleted'
                  }
                }
              ]
            }
          }
        );

- insert example #5 output

        # INSERT INTO "users" ("name", "user_id") SELECT "name", "id" FROM "users"
        # WHERE "deleted" IS NOT NULL

## update

- update example #1

        $sql->update(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'updated',
              value => { function => ['now'] }
            }
          ]
        );

- update example #1 output

        # UPDATE "users" SET "updated" = now()

- update example #2

        $sql->update(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name',
              value => { function => ['concat', '[deleted]', ' ', { column => 'name' }] }
            }
          ],
          where => [
            {
              'not-null' => {
                column => 'deleted'
              }
            }
          ]
        );

- update example #2 output

        # UPDATE "users" SET "name" = concat('[deleted]', ' ', "name") WHERE
        # "deleted" IS NOT NULL

- update example #3

        $sql->update(
          for => {
            table => 'users',
            alias => 'u1'
          },
          columns => [
            {
              column => 'updated',
              alias => 'u1',
              value => { function => ['now'] }
            }
          ],
          where => [
            {
              in => [
                {
                  column => 'id',
                  alias => 'u1'
                },
                {
                  subquery => {
                    select => {
                      from => {
                        table => 'users',
                        alias => 'u2'
                      },
                      columns => [
                        {
                          column => 'id',
                          alias => 'u2'
                        }
                      ],
                      joins => [
                        {
                          with => {
                            table => 'tasklists',
                            alias => 't1'
                          },
                          having => [
                            {
                              eq => [
                                {
                                  column => 'id',
                                  alias => 'u2'
                                },
                                {
                                  column => 'user_id',
                                  alias => 't1'
                                }
                              ]
                            }
                          ]
                        }
                      ],
                      where => [
                        {
                          eq => [
                            {
                              column => 'id',
                              alias => 'u2'
                            },
                            {
                              binding => 'user_id'
                            }
                          ]
                        }
                      ]
                    }
                  }
                }
              ]
            }
          ]
        );

- update example #3 output

        # UPDATE "users" "u1" SET "u1"."updated" = now() WHERE "u1"."id" IN (SELECT
        # "u2"."id" FROM "users" "u2" JOIN "tasklists" "t1" ON "u2"."id" =
        # "t1"."user_id" WHERE "u2"."id" = ?)

## delete

- delete example #1

        $sql->delete(
          from => {
            table => 'tasklists'
          }
        );

- delete example #1 output

        # DELETE FROM "tasklists"

- delete example #2

        $sql->delete(
          from => {
            table => 'tasklists'
          },
          where => [
            {
              'not-null' => {
                column => 'deleted'
              }
            }
          ]
        );

- delete example #2 output

        # DELETE FROM "tasklists" WHERE "deleted" IS NOT NULL

## table-create

- table-create example #1

        $sql->table_create(
          name => 'users',
          columns => [
            {
              name => 'id',
              type => 'integer',
              primary => 1
            }
          ]
        );

- table-create example #1 output

        # CREATE TABLE "users" ("id" integer PRIMARY KEY)

- table-create example #2

        $sql->table_create(
          name => 'users',
          columns => [
            {
              name => 'id',
              type => 'integer',
              primary => 1
            },
            {
              name => 'name',
              type => 'text',
            },
            {
              name => 'created',
              type => 'datetime',
            },
            {
              name => 'updated',
              type => 'datetime',
            },
            {
              name => 'deleted',
              type => 'datetime',
            },
          ]
        );

- table-create example #2 output

        # CREATE TABLE "users" ("id" integer PRIMARY KEY, "name" text, "created"
        # timestamp(0) without time zone, "updated" timestamp(0) without time zone,
        # "deleted" timestamp(0) without time zone)

- table-create example #3

        $sql->table_create(
          name => 'users',
          columns => [
            {
              name => 'id',
              type => 'integer',
              primary => 1
            },
            {
              name => 'name',
              type => 'text',
            },
            {
              name => 'created',
              type => 'datetime',
            },
            {
              name => 'updated',
              type => 'datetime',
            },
            {
              name => 'deleted',
              type => 'datetime',
            },
          ],
          temp => 1
        );

- table-create example #3 output

        # CREATE TEMPORARY TABLE "users" ("id" integer PRIMARY KEY, "name" text,
        # "created" timestamp(0) without time zone, "updated" timestamp(0) without
        # time zone, "deleted" timestamp(0) without time zone)

- table-create example #4

        $sql->table_create(
          name => 'people',
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => '*'
                }
              ]
            }
          }
        );

- table-create example #4 output

        # CREATE TABLE "people" AS SELECT * FROM "users"

## table-drop

- table-drop example #1

        $sql->table_drop(
          name => 'people'
        );

- table-drop example #1 output

        # DROP TABLE "people"

- table-drop example #2

        $sql->table_drop(
          name => 'people',
          condition => 'cascade'
        );

- table-drop example #2 output

        # DROP TABLE "people" CASCADE

## table-rename

- table-rename example #1

        $sql->table_rename(
          name => {
            old => 'peoples',
            new => 'people'
          }
        );

- table-rename example #1 output

        # ALTER TABLE "peoples" RENAME TO "people"

## index-create

- index-create example #1

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ]
        );

- index-create example #1 output

        # CREATE INDEX "index_users_name" ON "users" ("name")

- index-create example #2

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'email'
            }
          ],
          unique => 1
        );

- index-create example #2 output

        # CREATE UNIQUE INDEX "unique_users_email" ON "users" ("email")

- index-create example #3

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ],
          name => 'user_name_index'
        );

- index-create example #3 output

        # CREATE INDEX "user_name_index" ON "users" ("name")

- index-create example #4

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'email'
            }
          ],
          name => 'user_email_unique',
          unique => 1
        );

- index-create example #4 output

        # CREATE UNIQUE INDEX "user_email_unique" ON "users" ("email")

- index-create example #5

        $sql->index_create(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'login'
            },
            {
              column => 'email'
            }
          ]
        );

- index-create example #5 output

        # CREATE INDEX "index_users_login_email" ON "users" ("login", "email")

## index-drop

- index-drop example #1

        $sql->index_drop(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ]
        );

- index-drop example #1 output

        # DROP INDEX "index_users_name"

- index-drop example #2

        $sql->index_drop(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'email'
            }
          ],
          unique => 1
        );

- index-drop example #2 output

        # DROP INDEX "unique_users_email"

- index-drop example #3

        $sql->index_drop(
          for => {
            table => 'users'
          },
          columns => [
            {
              column => 'name'
            }
          ],
          name => 'user_email_unique'
        );

- index-drop example #3 output

        # DROP INDEX "user_email_unique"

## column-change

- column-change example #1

        $sql->column_change(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            nullable => 1
          }
        );

- column-change example #1 output

        # BEGIN TRANSACTION
        # ALTER TABLE "users" ALTER "accessed" TYPE timestamp(0) without time zone
        # ALTER TABLE "users" ALTER "accessed" DROP NOT NULL
        # ALTER TABLE "users" ALTER "accessed" DROP DEFAULT
        # COMMIT

- column-change example #2

        $sql->column_change(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            default => { function => ['now'] }
          }
        );

- column-change example #2 output

        # BEGIN TRANSACTION
        # ALTER TABLE "users" ALTER "accessed" TYPE timestamp(0) without time zone
        # ALTER TABLE "users" ALTER "accessed" SET DEFAULT now()
        # COMMIT

- column-change example #3

        $sql->column_change(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            default => { function => ['now'] },
            nullable => 1,
          }
        );

- column-change example #3 output

        # BEGIN TRANSACTION
        # ALTER TABLE "users" ALTER "accessed" TYPE timestamp(0) without time zone
        # ALTER TABLE "users" ALTER "accessed" DROP NOT NULL
        # ALTER TABLE "users" ALTER "accessed" SET DEFAULT now()
        # COMMIT

## column-create

- column-create example #1

        $sql->column_create(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime'
          }
        );

- column-create example #1 output

        # ALTER TABLE "users" ADD COLUMN "accessed" timestamp(0) without time zone

- column-create example #2

        $sql->column_create(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            nullable => 1
          }
        );

- column-create example #2 output

        # ALTER TABLE "users" ADD COLUMN "accessed" timestamp(0) without time zone
        # NULL

- column-create example #3

        $sql->column_create(
          for => {
            table => 'users'
          },
          column => {
            name => 'accessed',
            type => 'datetime',
            nullable => 1,
            default => {
              function => ['now']
            }
          }
        );

- column-create example #3 output

        # ALTER TABLE "users" ADD COLUMN "accessed" timestamp(0) without time zone
        # NULL DEFAULT now()

- column-create example #4

        $sql->column_create(
          for => {
            table => 'users'
          },
          column => {
            name => 'ref',
            type => 'uuid',
            primary => 1
          }
        );

- column-create example #4 output

        # ALTER TABLE "users" ADD COLUMN "ref" uuid PRIMARY KEY

## column-drop

- column-drop example #1

        $sql->column_drop(
          table => 'users',
          column => 'accessed'
        );

- column-drop example #1 output

        # ALTER TABLE "users" DROP COLUMN "accessed"

## column-rename

- column-rename example #1

        $sql->column_rename(
          for => {
            table => 'users'
          },
          name => {
            old => 'accessed',
            new => 'accessed_at'
          }
        );

- column-rename example #1 output

        # ALTER TABLE "users" RENAME COLUMN "accessed" TO "accessed_at"

## constraint-create

- constraint-create example #1

        $sql->constraint_create(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          }
        );

- constraint-create example #1 output

        # ALTER TABLE "users" ADD CONSTRAINT "foreign_users_profile_id_profiles_id"
        # FOREIGN KEY ("profile_id") REFERENCES "profiles" ("id")

- constraint-create example #2

        $sql->constraint_create(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          },
          name => 'user_profile_id'
        );

- constraint-create example #2 output

        # ALTER TABLE "users" ADD CONSTRAINT "user_profile_id" FOREIGN KEY
        # ("profile_id") REFERENCES "profiles" ("id")

- constraint-create example #3

        $sql->constraint_create(
          on => {
            update => 'cascade',
            delete => 'cascade'
          },
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          },
          name => 'user_profile_id'
        );

- constraint-create example #3 output

        # ALTER TABLE "users" ADD CONSTRAINT "user_profile_id" FOREIGN KEY
        # ("profile_id") REFERENCES "profiles" ("id") ON DELETE CASCADE ON UPDATE
        # CASCADE

## constraint-drop

- constraint-drop example #1

        $sql->constraint_drop(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          }
        );

- constraint-drop example #1 output

        # ALTER TABLE "users" DROP CONSTRAINT "foreign_users_profile_id_profiles_id"

- constraint-drop example #2

        $sql->constraint_drop(
          source => {
            table => 'users',
            column => 'profile_id'
          },
          target => {
            table => 'profiles',
            column => 'id'
          },
          name => 'user_profile_id'
        );

- constraint-drop example #2 output

        # ALTER TABLE "users" DROP CONSTRAINT "user_profile_id"

## database-create

- database-create example #1

        $sql->database_create(
          name => 'todoapp'
        );

- database-create example #1 output

        # CREATE DATABASE "todoapp"

## database-drop

- database-drop example #1

        $sql->database_drop(
          name => 'todoapp'
        );

- database-drop example #1 output

        # DROP DATABASE "todoapp"

## schema-create

- schema-create example #1

        $sql->schema_create(
          name => 'private',
        );

- schema-create example #1 output

        # CREATE SCHEMA "private"

## schema-drop

- schema-drop example #1

        $sql->schema_drop(
          name => 'private',
        );

- schema-drop example #1 output

        # DROP SCHEMA "private"

## schema-rename

- schema-rename example #1

        $sql->schema_rename(
          name => {
            old => 'private',
            new => 'restricted'
          }
        );

- schema-rename example #1 output

        # ALTER SCHEMA "private" RENAME TO "restricted"

## transaction

- transaction example #1

        $sql->transaction(
          queries => [
            {
              'table-create' => {
                name => 'users',
                columns => [
                  {
                    name => 'id',
                    type => 'integer',
                    primary => 1
                  }
                ]
              }
            }
          ]
        );

- transaction example #1 output

        # BEGIN TRANSACTION
        # CREATE TABLE "users" ("id" integer PRIMARY KEY)
        # COMMIT

- transaction example #2

        $sql->transaction(
          mode => [
            'exclusive'
          ],
          queries => [
            {
              'table-create' => {
                name => 'users',
                columns => [
                  {
                    name => 'id',
                    type => 'integer',
                    primary => 1
                  }
                ]
              }
            }
          ]
        );

- transaction example #2 output

        # BEGIN TRANSACTION EXCLUSIVE
        # CREATE TABLE "users" ("id" integer PRIMARY KEY)
        # COMMIT

## view-create

- view-create example #1

        $sql->view_create(
          name => 'active_users',
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => '*'
                }
              ],
              where => [
                {
                  'not-null' => {
                    column => 'deleted'
                  }
                }
              ]
            }
          }
        );

- view-create example #1 output

        # CREATE VIEW "active_users" AS SELECT * FROM "users" WHERE "deleted" IS NOT
        # NULL

- view-create example #2

        $sql->view_create(
          name => 'active_users',
          query => {
            select => {
              from => {
                table => 'users'
              },
              columns => [
                {
                  column => '*'
                }
              ],
              where => [
                {
                  'not-null' => {
                    column => 'deleted'
                  }
                }
              ]
            }
          },
          temp => 1
        );

- view-create example #2 output

        # CREATE TEMPORARY VIEW "active_users" AS SELECT * FROM "users" WHERE
        # "deleted" IS NOT NULL

## view-drop

- view-drop example #1

        $sql->view_drop(
          name => 'active_users'
        );

- view-drop example #1 output

        # DROP VIEW "active_users"

## union

- union example #1

        $sql->union(
          queries => [
            {
              select => {
                from => {
                  table => 'customers',
                },
                columns => [
                  {
                    column => 'name',
                  }
                ]
              }
            },
            {
              select => {
                from => {
                  table => 'employees',
                },
                columns => [
                  {
                    column => 'name',
                  }
                ]
              }
            }
          ]
        );

- union example #1 output

        # (SELECT "name" FROM "customers") UNION (SELECT "name" FROM "employees")

# AUTHOR

Al Newkirk, `awncorp@cpan.org`

# LICENSE

Copyright (C) 2011-2019, Al Newkirk, et al.

This is free software; you can redistribute it and/or modify it under the terms
of the The Apache License, Version 2.0, as elucidated in the ["license
file"](https://github.com/iamalnewkirk/sql-engine/blob/master/LICENSE).

# PROJECT

[Wiki](https://github.com/iamalnewkirk/sql-engine/wiki)

[Project](https://github.com/iamalnewkirk/sql-engine)

[Initiatives](https://github.com/iamalnewkirk/sql-engine/projects)

[Milestones](https://github.com/iamalnewkirk/sql-engine/milestones)

[Contributing](https://github.com/iamalnewkirk/sql-engine/blob/master/CONTRIBUTE.md)

[Issues](https://github.com/iamalnewkirk/sql-engine/issues)
