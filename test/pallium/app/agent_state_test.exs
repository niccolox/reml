defmodule Pallium.App.AgentStateTest do
  use ExUnit.Case

  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Message
  alias PalliumCore.Core.Transaction, as: Tx
  alias Pallium.App.Store
  alias Pallium.App.TransactionController
  alias MerklePatriciaTree.Trie

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("state", address)
    agent_rlp = %Agent{code: code} |> Agent.encode()
    data = [agent_rlp, ""]
    %Tx{type: :create, from: address, data: data}
    |> TransactionController.execute()
    {:ok, address: address, agent: agent_rlp}
  end

  test "sets initial state", context do
    assert "1" == Store.get_state_value!(context.address, "a")
  end

  test "modifies state", context do
    msg_rlp = %Message{action: :set, props: "a=5"} |> Message.encode()
    %Tx{type: :send, to: context.address, data: msg_rlp}
    |> TransactionController.execute()
    assert "5" == Store.get_state_value!(context.address, "a")
  end

  test "restores state on failure", context do
    msg_rlp = %Message{action: :set_and_fail, props: "a=5"} |> Message.encode()
    %Tx{type: :send, to: context.address, data: msg_rlp}
    |> TransactionController.execute()
    assert "1" == Store.get_state_value!(context.address, "a")
   end

   test "hash empty root hash as initial state" do
     agent = %Agent{}
     assert Trie.empty_trie_root_hash() == agent.state
   end
end
