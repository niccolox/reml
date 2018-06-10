defmodule AgentTest do
  use ExUnit.Case, async: false
  alias Pallium.Myelin.Agent
  alias Pallium.Myelin.Store

  doctest Agent

  @sender "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"
  @recipient "f26568ad9e5557a70aace0e699888ddc71c74b31102d5d3ab5161dd496e3f64d"

  setup_all do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    <<>> |> Agent.new() |> Agent.put(@sender)
    <<>> |> Agent.new() |> Agent.put(@recipient)
  end

  test "should mint spike" do
    Agent.transfer(@sender, "0x", 100)
    assert Agent.get_balance(@sender) == {:ok, 100}
  end

  test "should transfer spike" do
    Agent.transfer(@recipient, @sender, 50)
    assert Agent.get_balance(@sender) == {:ok, 50}
    assert Agent.get_balance(@recipient) == {:ok, 50}
  end

  # test "should not transfer spike" do
  #   Agent.transfer(@recipient, @sender, 100)
  #   assert Agent.get_balance(@sender) == {:ok, 50}
  #   assert Agent.get_balance(@recipient) == {:ok, 50}    
  # end  
end
