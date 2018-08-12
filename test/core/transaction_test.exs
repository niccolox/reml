defmodule TransactionTest do
  use ExUnit.Case

  alias MerklePatriciaTree.{Test, Trie}
  alias Pallium.Core.Agent
  alias Pallium.Core.Store
  alias Pallium.Core.Message
  alias Pallium.Core.Transaction, as: Tx

  doctest Tx

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  #@recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    Test.random_ets_db() |> Trie.new() |> Store.start_link()
    :ok
  end

  test "should return new RLP encoded transaction struct" do
    raw = {0, :create, @sender, <<>>, 0, <<>>}
    rlp = Tx.new(raw)
    decoded = rlp |> ExRLP.decode(encoding: :hex) |> Tx.deserialize()
    assert decoded.to == @sender
  end

  test "should execution create type transaction" do
    sender_code = @sender |> Helpers.get_agent_code
    agent_hex_rlp = Agent.new(sender_code |> Helpers.to_hex())
    {0, :create, @sender, <<>>, 0, agent_hex_rlp} |> Tx.new() |> Helpers.from_hex() |> Tx.execute()
    agent = Agent.get_agent(@sender)
    assert agent.code == sender_code
  end

  test "should execution send type transaction" do
    sender_code = @sender |> Helpers.get_agent_code
    agent_hex_rlp = Agent.new(sender_code |> Helpers.to_hex())
    {0, :create, @sender, <<>>, 0, agent_hex_rlp} |> Tx.new() |> Helpers.from_hex() |> Tx.execute()

    msg = Message.new("foo", <<>>)
    {:ok, result} = {0, :send, @sender, <<>>, 0, msg} |> Tx.new() |> Helpers.from_hex() |> Tx.execute()
    assert result == "bar"
  end
end
