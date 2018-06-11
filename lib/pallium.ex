defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Myelin
  alias Myelin.Store
  alias Myelin.Transaction, as: Tx

  def start() do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    Pallium.App.start_link()
  end

  def create_agent(code \\ <<>>) do
    {secret_key, public_key} = Ed25519.generate_key_pair()
    address = Myelin.Address.new(public_key) |> Helpers.to_hex()
    agent = Myelin.Agent.new(code)
    response = {0, :create, address, <<>>, 0, agent} |> Tx.create() |> Tx.send()
    {:ok, address}
  end

  def mint(address, value) do
    {0, address, "0x", value, <<>>} |> Tx.create() |> Tx.send()
  end

  def transfer(to, from, value) do
    {0, to, from, value, <<>>} |> Tx.create() |> Tx.send()
  end
end
