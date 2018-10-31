defmodule Reml.Vendore.CassandraTest do
  use ExUnit.Case

  setup_all do
    {:ok, pid} = Xandra.start_link()
    Xandra.execute!(pid, "CREATE KEYSPACE test WITH REPLICATION = {
                          'class' : 'SimpleStrategy',
                          'replication_factor' : 1 }")
    Xandra.execute!(pid, "USE test")
    statement = "CREATE TABLE users (code int, name text, PRIMARY KEY (code, name))"
    Xandra.execute!(pid, statement)
    {:ok, db: pid}
  end

  test "should put/get value", context do
    statement = "INSERT INTO users (code, name) VALUES (1, 'Marge')"
    Xandra.execute!(context.db, statement)

    statement = "SELECT name FROM users WHERE code = :code"
    assert {:ok, prepared} = Xandra.prepare(context.db, statement)
    # Successive call to prepare uses cache.
    assert {:ok, ^prepared} = Xandra.prepare(context.db, statement)

    assert {:ok, page} = Xandra.execute(context.db, prepared, [1])

    assert Enum.to_list(page) == [
             %{"name" => "Marge"}
           ]

    Xandra.execute!(context.db, "DROP KEYSPACE test")
  end
end
