defmodule AgentStateTest do
  use ExUnit.Case

  alias Pallium.Core.Agent
  alias Pallium.Core.Message

  setup do
    address = AgentHelpers.random_address()
    agent =
      AgentHelpers.agent_code("state", address)
      |> Helpers.to_hex()
      |> Agent.new()
    data = [agent, ""]
    TxHelpers.run(0, :create, address, <<>>, 0, data)
    {:ok, address: address, agent: agent}
  end

  test "sets initial state", context do
    assert Agent.get_state_value(context.address, "a") == "1"
  end

  test "modifies state", context do
    msg = Message.new("set", "a=5")
    TxHelpers.run(0, :send, context.address, <<>>, 0, msg)
    assert Agent.get_state_value(context.address, "a") == "5"
  end

  test "restores state on failure", context do
    msg = Message.new("set_and_fail", "a=5")
    TxHelpers.run(0, :send, context.address, <<>>, 0, msg)
    assert Agent.get_state_value(context.address, "a") == "1"
   end
end
