defmodule AgentTest do
  use ExUnit.Case, async: false
  alias Pallium.Core.{Agent, Message, Store}
  alias Pallium.Env.Channel, as: Chan

  doctest Agent

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    :ok
  end

  test "should create new agent struct and encode/decode it" do
    sender_code = @sender |> Helpers.get_agent_code
    agent_hex_rlp = Agent.new(sender_code |> Helpers.to_hex())
    agent_decode = agent_hex_rlp |> ExRLP.decode(encoding: :hex) |> Agent.deserialize()
    assert agent_decode.code == sender_code
  end

  test "should create agent to Store and get it" do
    sender_code = @sender |> Helpers.get_agent_code
    {:ok, address} = sender_code |> Helpers.to_hex |> Agent.new |> Agent.create(@sender)
    agent = Agent.get_agent(address)
    assert agent.code == sender_code
  end

  test "should execute construct function from agent code and set state" do
    sender_code = @sender |> Helpers.get_agent_code
    {:ok, address} = sender_code |> Helpers.to_hex |> Agent.new |> Agent.create(@sender)
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
