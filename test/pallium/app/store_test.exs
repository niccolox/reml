defmodule Pallium.App.StoreTest do
  use ExUnit.Case

  alias Pallium.App.Store
  alias PalliumCore.Core.Agent

  doctest Store

  setup do
    address = AgentHelpers.random_address()
    agent = %Agent{}
    {:ok, address: address, agent: agent}
  end

  test "stores agent and retrieves it", context do
    assert nil == Store.get_agent(context.address)
    assert :ok == Store.update_agent(context.address, context.agent)
    assert context.agent == Store.get_agent(context.address)
  end

  test "updates agent state", context do
    {key, value} = {"key", "123"}
    get = fn -> Store.get_state_value(context.address, key) end

    assert {:error, "Agent not found"} = get.()
    Store.update_agent(context.address, context.agent)
    assert {:ok, nil} == get.()
    Store.update_state_value(context.address, key, value)
    assert {:ok, value} == get.()
  end

  test "sets agent state hash root", context do
    key = "key"
    original_state = context.agent.state
    Store.update_agent(context.address, context.agent)
    Store.update_state_value(context.address, key, "1")
    modified_state = Store.get_agent(context.address).state
    Store.update_state_value(context.address, key, "2")

    assert "2" == Store.get_state_value!(context.address, key)
    Store.reset_state_hash(context.address, modified_state)
    assert "1" == Store.get_state_value!(context.address, key)
    Store.reset_state_hash(context.address, original_state)
    assert nil == Store.get_state_value!(context.address, key)
  end

  test "sets agent state map", context do
    map = %{a: "1", b: "2"}
    Store.update_agent(context.address, context.agent)
    assert :ok == Store.set_state(context.address, map)
    assert "1" == Store.get_state_value!(context.address, "a")
    assert "2" == Store.get_state_value!(context.address, "b")
  end
end
