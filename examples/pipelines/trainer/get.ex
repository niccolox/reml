defmodule Reml.Examples.Pipelines.Trainer.Get do
  @moduledoc """
  Get MNIST dataset from Cassandra DB
  """
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, [])
  end

  def init(state) do
    {:producer, state}
  end

  def get(pid, db) do
    GenStage.cast(pid, {:get, db})
  end

  def handle_cast({:get, db}, state) do
    train_statement = "SELECT vector, lable FROM mnist_train LIMIT 100"
    test_statement = "SELECT vector, lable FROM mnist_test LIMIT 100"

    train_pre = Xandra.prepare(db, train_statement)
    test_pre = Xandra.prepare(db, test_statement)

    {:ok, train} = Xandra.execute(db, train_pre, [1])
    {:ok, test} = Xandra.execute(db, test_pre, [1])

    {:noreply, [train, test], state}
  end
end
