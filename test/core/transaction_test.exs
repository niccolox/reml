defmodule TransactionTest do
  use ExUnit.Case

  alias Pallium.Core.Agent
  alias Pallium.Core.Message
  alias Pallium.Core.Transaction, as: Tx

  doctest Tx

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("foo", address)
    {:ok, address: address, code: code}
  end

  test "returns new RLP encoded transaction struct", context do
    decoded =
      {0, :create, context.address, <<>>, 0, <<>>}
      |> Tx.new()
      |> ExRLP.decode(encoding: :hex)
      |> Tx.deserialize()
    assert decoded.to == context.address
  end

  test "executes :create type transaction", context do
    agent_hex_rlp = context.code |> Helpers.to_hex() |> Agent.new()
    params = ""
    data = [agent_hex_rlp, params]
    TxHelpers.run(0, :create, context.address, <<>>, 0, data)
    agent = Agent.get_agent(context.address)
    assert agent.code == context.code
  end

  test "executes :send transaction", context do
    agent_hex_rlp = context.code |> Helpers.to_hex() |> Agent.new()
    params = ""
    data = [agent_hex_rlp, params]
    TxHelpers.run(0, :create, context.address, <<>>, 0, data)
    msg = Message.new("foo", <<>>)
    {:ok, result} = TxHelpers.run(0, :send, context.address, <<>>, 0, msg)

    assert result == "bar"
  end
end
