defmodule Pallium.Api.Resolvers.Transaction do
  @moduledoc false

  alias Pallium.Core.Transaction, as: Tx

  def send_tx(_parent, args, _resolution) do
    type = String.to_atom(args.type)
    data = args.data |> Helpers.from_hex()
    {0, type, args.to, args.from, args.value, data} |> Tx.create() |> Tx.send()
    {:ok, %{rlp: "123"}}
  end

  @doc """
  Creates and sends a transaction to create an agent in the Store

  ## Arguments
    - args.to:   Address of new agent
    - args.data: Structure of the agent encoded by RLP
  """
  def create(_parent, args, _resolution) do
    {0, :create, args.to, <<>>, 0, args.data} |> Tx.create() |> Tx.send()
    {:ok, %{rlp: "123"}}
  end

  def mint(_parent, args, _resolution) do
    {0, :transfer, args.to, "0x", args.value, <<>>} |> Tx.create() |> Tx.send()
    {:ok, %{rlp: "123"}}
  end

  def transfer(_parent, args, _resolution) do
    {0, :transfer, args.to, args.from, args.value, <<>>} |> Tx.create() |> Tx.send()
    {:ok, %{rlp: "123"}}
  end

  @doc """
  Creates and sends a transaction to forward the message to the agent

  ## Arguments
    - args.to:      Address of receiving agent
    - args.from:    Address of sending agent
    - args.message: Structure of the message encoded by RLP
  """
  def send_msg(_parent, args, _resolution) do
    {0, :send, args.to, args.from, args.value, args.message} |> Tx.create() |> Tx.send()
    {:ok, %{rlp: "123"}}
  end
end
