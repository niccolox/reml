defmodule AgentTest do
  use ExUnit.Case, async: false

  alias Pallium.Core.Agent

  doctest Agent

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("foo", address)
    {:ok, address: address, code: code}
  end

  test "creates new agent struct and encodes/decodes it", context do
    agent_decode =
      context.code
      |> Helpers.to_hex()
      |> Agent.new()
      |> ExRLP.decode(encoding: :hex)
      |> Agent.deserialize()

    assert agent_decode.code == context.code
  end

  test "creates agent to Store and gets it", context do
    {:ok, address} =
      context.code
      |> Helpers.to_hex()
      |> Agent.new()
      |> Agent.create(context.address)

    agent = Agent.get_agent(address)
    assert agent.code == context.code
  end

  test "executes construct function from agent code and sets state", context do
    {:ok, address} =
      context.code
      |> Helpers.to_hex()
      |> Agent.new()
      |> Agent.create(context.address)

    assert Agent.get_state_value(address, "foo") == "bar"
    assert Agent.get_state_value(address, "hello") == "Hello, world!"
  end

  # # test "should handle message" do
  # #   message = Message.create(@sender, "foo")
  # #   assert Agent.send(@sender, message) == "bar"
  # # end
  #
  # test "should mint spike" do
  #   Agent.transfer(@sender, "0x", 100)
  #   assert Agent.get_balance(@sender) == {:ok, 100}
  # end
  #
  # test "should transfer spike" do
  #   Agent.transfer(@sender, "0x", 100)
  #   Agent.transfer(@recipient, @sender, 50)
  #   assert Agent.get_balance(@sender) == {:ok, 50}
  #   assert Agent.get_balance(@recipient) == {:ok, 50}
  # end
  #
  # test "should not transfer spike" do
  #   Agent.transfer(@sender, "0x", 50)
  #
  #   assert Agent.transfer(@recipient, @sender, 100) ==
  #            {:reject, "sender account insufficient funds"}
  # end
  #
  # test "update state" do
  #   Agent.put_state(@recipient, "foo", "bar")
  #   assert Agent.get_state(@recipient, "foo") == "bar"
  #
  #   Agent.put_state(@recipient, "foo", "baz")
  #   assert Agent.get_state(@recipient, "foo") == "baz"
  # end
  #
  # test "set state" do
  #   state = %{foo: "bar", hello: "world"}
  #   Agent.set_state(@recipient, state)
  #
  #   assert Agent.get_state(@recipient, "foo") == "bar"
  #   assert Agent.get_state(@recipient, "hello") == "world"
  # end
end
