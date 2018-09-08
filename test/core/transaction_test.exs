defmodule TransactionTest do
  use ExUnit.Case

  alias PalliumCore.Core.Agent, as: Ag
  alias Pallium.Core.Agent
  alias PalliumCore.Core.Message
  alias Pallium.Core.Transaction, as: Tx

  doctest Tx

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("foo", address)
    {:ok, address: address, code: code}
  end

  test "executes :create type transaction", context do
    code = context.code
    agent_hex_rlp = %Ag{code: code} |> Ag.encode(:hex)
    params = ""
    data = [agent_hex_rlp, params]
    TxHelpers.run(0, :create, context.address, <<>>, 0, data)
    agent = Agent.get_agent(context.address)
    assert agent.code == context.code
  end

  test "executes :send transaction", context do
    code = context.code
    agent_hex_rlp = %Ag{code: code} |> Ag.encode(:hex)
    params = ""
    data = [agent_hex_rlp, params]
    TxHelpers.run(0, :create, context.address, <<>>, 0, data)
    msg = %Message{action: :foo, props: ""} |> Message.encode()
    {:ok, result} = TxHelpers.run(0, :send, context.address, <<>>, 0, msg)

    assert result == "bar"
  end
end
