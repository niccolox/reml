defmodule AgentStateTest do
  use ExUnit.Case

  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Message
  alias PalliumCore.Crypto
  alias Pallium.Core.Agent, as: AgentT
  alias MerklePatriciaTree.Trie

  setup do
    address = AgentHelpers.random_address()
    code = AgentHelpers.agent_code("state", address)
    agent_rlp = %Agent{code: code} |> Agent.encode() |> Crypto.to_hex()
    data = [agent_rlp, ""]
    TxHelpers.run(0, :create, address, <<>>, 0, data)
    {:ok, address: address, agent: agent_rlp}
  end

  test "sets initial state", context do
    assert AgentT.get_state_value(context.address, "a") == "1"
  end

  test "modifies state", context do
    msg_rlp = %Message{action: :set, props: "a=5"} |> Message.encode()
    TxHelpers.run(0, :send, context.address, <<>>, 0, msg_rlp)
    assert AgentT.get_state_value(context.address, "a") == "5"
  end

  test "restores state on failure", context do
    msg_rlp = %Message{action: :set_and_fail, props: "a=5"} |> Message.encode()
    TxHelpers.run(0, :send, context.address, <<>>, 0, msg_rlp)
    assert AgentT.get_state_value(context.address, "a") == "1"
   end

   test "hash empty root hash as initial state" do
     agent = %Agent{}
     assert agent.state == Trie.empty_trie_root_hash()
   end
end
