defmodule TransactionTest do
  use ExUnit.Case

  alias Pallium.Myelin.Transaction, as: Tx
  alias Pallium.Myelin.Store
  alias Pallium.Myelin.Agent

  doctest Tx

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    :ok
  end

  test "create agent" do
    sender_code = Helpers.get_agent_code(@sender)
    sender_code |> Agent.new() |> Agent.create(@sender)
    
    assert Agent.get_balance(@sender) == {:ok, 0}
  end

end
