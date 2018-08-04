defmodule EnvTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Pallium.Env

  alias Pallium.Core.{Agent,Message,Store}

  @add_agent "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @square_agent "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    add_agent_code = Helpers.get_add_agent_code(@add_agent)
    square_agent_code = Helpers.get_square_agent_code(@square_agent)

    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    add_agent_code |> Agent.new() |> Agent.create(@add_agent)
    square_agent_code |> Agent.new() |> Agent.create(@square_agent)
    :ok
  end

  test "should additional two numbers" do
    msg = Message.create("run", ["5.0", "5.0"])
    assert Agent.send(@add_agent, msg) == {:ok, "10.0"}
  end

  test "should square number" do
    msg = Message.create("run", ["5.0"])
    assert Agent.send(@square_agent, msg) == {:ok, "25.0"}
  end

  test "should open channel" do

    msg = Message.create("deploy", [])
    {:ok, response} = Agent.send(@add_agent, msg)
    agent_p = response |> Helpers.pid_from_string
    observer = Helpers.observer()
    send agent_p, {:connect, observer}

    output = capture_io fn ->
      Process.group_leader(observer, self())
      send agent_p, {:run, ["5.0", "5.0"]}
    end

    assert_receive {:io_request, _, _, {:put_chars, :unicode, "10.0\n"}}

    Process.exit(observer, :kill)
    Process.exit(agent_p, :kill)
  end
end
