defmodule Reml.Tendermint.TxExecutorTest do
  use ExUnit.Case

  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Message
  alias PalliumCore.Core.Transaction, as: Tx
  alias Reml.Tendermint.TxExecutor
  alias Reml.App.Store

  doctest Tx

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("foo", address)
    {:ok, address: address, code: code}
  end

  test "executes :create type transaction", context do
    code = context.code
    agent_hex_rlp = %Agent{code: code} |> Agent.encode()
    params = ""
    data = [agent_hex_rlp, params]

    %Tx{type: :create, from: context.address, data: data}
    |> TxExecutor.execute_tx()

    agent = Store.get_agent(context.address)
    assert agent.code == context.code
  end

  test "executes :send transaction", context do
    code = context.code
    agent_hex_rlp = %Agent{code: code} |> Agent.encode()
    params = ""
    data = [agent_hex_rlp, params]

    %Tx{type: :create, from: context.address, data: data}
    |> TxExecutor.execute_tx()

    msg = %Message{action: :foo, props: ""} |> Message.encode()

    {:ok, result} =
      %Tx{type: :send, to: context.address, data: msg}
      |> TxExecutor.execute_tx()

    assert result == "bar"
  end
end
