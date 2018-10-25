defmodule Reml.App.AgentControllerTest do
  use ExUnit.Case, async: false

  alias Reml.App.AgentController
  alias Reml.App.Store
  alias PalliumCore.Core.Agent

  doctest Agent

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("foo", address)
    {:ok, address: address, code: code}
  end

  test "creates agent to Store and gets it", context do
    {:ok, address} =
      %Agent{code: context.code}
      |> AgentController.create(context.address, %{})

    agent = Store.get_agent(address)
    assert agent.code == context.code
  end

  test "executes construct function from agent code and sets state", context do
    {:ok, address} =
      %Agent{code: context.code}
      |> AgentController.create(context.address, %{})

    assert {:ok, "bar"} == Store.get_state_value(address, "foo")
    assert {:ok, "Hello, world!"} == Store.get_state_value(address, "hello")
  end
end
