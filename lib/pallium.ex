defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Myelin
  alias Myelin.Store
  alias Myelin.Transaction, as: Tx
  alias Pallium.Env.Channel, as: Chan

  def start() do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    Pallium.App.start_link()
  end

  def create_agent() do
    {secret_key, public_key} = Ed25519.generate_key_pair()
    address = Myelin.Address.new(public_key) |> Helpers.to_hex()
    code = Helpers.get_agent_code(address)
    agent = Myelin.Agent.new(code)
    response = {0, :create, address, <<>>, 0, agent} |> Tx.create() |> Tx.send()
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

  def new_chan(to) do
    chan = Chan.open() |> Helpers.pid_to_binary
    {0, :channel, to, <<>>, 0, chan} |> Tx.create |> Tx.send()
  end
end
