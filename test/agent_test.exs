defmodule AgentTest do
  use ExUnit.Case, async: false
  alias Pallium.Myelin.Agent
  alias Pallium.Myelin.Store
  alias Pallium.Myelin.Message

  doctest Agent

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    sender_atom = agent_atom = {:__aliases__, [alias: false], [String.to_atom(@sender)]}

    sender =
      quote do
        defmodule unquote(sender_atom) do
          @behaviour Pallium.Env.AgentBehaviour
          def construct(_agent) do
            state = %{foo: "bar", hello: "Hello, world!"}
            Pallium.Env.set_state(_agent, state)
          end

          def handle(_agent, action, data) do
            case action do
              "foo" -> Pallium.Env.get_value(_agent, "foo")
              "hello" -> Pallium.Env.get_value("hello")
            end
          end
        end
      end

    [{_, sender_code}] = Code.compile_quoted(sender)

    :code.purge(String.to_atom(@sender))
    :code.delete(String.to_atom(@sender))

    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    sender_code |> Agent.new() |> Agent.create(@sender)
    <<>> |> Agent.new() |> Agent.put(@recipient)
    :ok
  end

  test "should constructed" do
    assert Agent.get_state(@sender, "foo") == "bar"
    assert Agent.get_state(@sender, "hello") == "Hello, world!"
  end

  test "should handle message" do
    message = Message.create(@sender, "foo", <<>>)
    assert Agent.send(@sender, message) == "bar"
  end

  test "should mint spike" do
    Agent.transfer(@sender, "0x", 100)
    assert Agent.get_balance(@sender) == {:ok, 100}
  end

  test "should transfer spike" do
    Agent.transfer(@sender, "0x", 100)
    Agent.transfer(@recipient, @sender, 50)
    assert Agent.get_balance(@sender) == {:ok, 50}
    assert Agent.get_balance(@recipient) == {:ok, 50}
  end

  test "should not transfer spike" do
    Agent.transfer(@sender, "0x", 50)

    assert Agent.transfer(@recipient, @sender, 100) ==
             {:reject, "sender account insufficient funds"}
  end

  test "update state" do
    Agent.put_state(@recipient, "foo", "bar")
    assert Agent.get_state(@recipient, "foo") == "bar"

    Agent.put_state(@recipient, "foo", "baz")
    assert Agent.get_state(@recipient, "foo") == "baz"
  end

  test "set state" do
    state = %{foo: "bar", hello: "world"}
    Agent.set_state(@recipient, state)

    assert Agent.get_state(@recipient, "foo") == "bar"
    assert Agent.get_state(@recipient, "hello") == "world"
  end
end
