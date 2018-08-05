defmodule TransactionTest do
  use ExUnit.Case

  alias Pallium.Core.Transaction, as: Tx
  alias Pallium.Core.Store
  alias Pallium.Core.Agent

  doctest Tx

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    :ok
  end

  test "should execution create agent transaction" do
    sender_code = @sender |> Helpers.get_agent_code
    data = agent_hex_rlp = Agent.new(sender_code |> Helpers.to_hex())
    {0, :create, @sender, <<>>, 0, data} |> Tx.create() |> Tx.serialize() |> ExRLP.encode(encoding: :hex) |> Tx.execute()
    agent = Agent.get_agent(@sender)
    assert agent.code == sender_code
  end
end
