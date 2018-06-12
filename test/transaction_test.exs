defmodule TransactionTest do
  use ExUnit.Case

  alias Pallium.Myelin.Transaction, as: Tx
  alias Pallium.Myelin.Store
  alias Pallium.Myelin.Agent

  doctest Tx

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    :ok
  end

  test "test create type" do
    agent = Agent.new(<<>>)

    {0, :create, @sender, <<>>, 0, agent}
    |> Tx.create()
    |> Tx.serialize()
    |> ExRLP.encode()
    |> Tx.execute()

    assert Agent.get_balance(@sender) == {:ok, 0}
  end

  test "test dispatch type" do
    agent_atom = agent_atom = {:__aliases__, [alias: false], [String.to_atom(@sender)]}

    agent =
      quote do
        defmodule unquote(agent_atom) do
          @behaviour Pallium.Env.AgentBehaviour
          def construct() do
            state = %{foo: "bar", hello: "world"}
            Pallium.Env.set_state(state)
          end

          def get_message(action, data) do
            case action do
              "foo" -> Pallium.Env.get_value("foo")
              "hello" -> Pallium.Env.get_value("hello")
            end
          end
        end
      end

    [{_, object_code}] = Code.compile_quoted(agent)

    :code.purge(String.to_atom(@sender))
    :code.delete(String.to_atom(@sender))

    agent = Agent.new(object_code)

    {0, :create, @sender, <<>>, 0, agent}
    |> Tx.create()
    |> Tx.serialize()
    |> ExRLP.encode()
    |> Tx.execute()

    created_agent = Agent.get_agent(@sender)
    assert created_agent.code == object_code

    result =
      {0, :dispatch, @sender, <<>>, 0, <<>>}
      |> Tx.create()
      |> Tx.serialize()
      |> ExRLP.encode()
      |> Tx.execute()

    assert result == :hello
  end
end
