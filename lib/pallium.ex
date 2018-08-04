defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Core.{Address, Agent, Store}
  alias Pallium.Core.Transaction, as: Tx

  def start() do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    Pallium.App.init()
    Pallium.Api.Server.start_link()
  end

  def create_agent() do
    {_secret_key, public_key} = Ed25519.generate_key_pair()
    address = public_key |> Address.new() |> Helpers.to_hex()
    code = Helpers.get_add_agent_code(address)
    agent = Agent.new(code)
    {0, :create, address, <<>>, 0, agent} |> Tx.create() |> Tx.send()
    {:ok, address}
  end

  def mint(address, value) do
    {0, address, "0x", value, <<>>} |> Tx.create() |> Tx.send()
  end

  def transfer(to, from, value) do
    {0, :transfer, to, from, value, <<>>} |> Tx.create() |> Tx.send()
  end

  def send(to, message) do
    {0, :send, to, <<>>, 0, message} |> Tx.create() |> Tx.send()
  end
end
