defmodule Pallium.Api.Resolvers.Transaction do
  @moduledoc false

  alias Pallium.App.TransactionController
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  def send_tx(_parent, args, _resolution) do
    %Tx{
      type: String.to_atom(args.type),
      to: args.to,
      from: args.from,
      value: args.value,
      data: Crypto.from_hex(args.data)
    }
    |> TransactionController.send()
    {:ok, %{rlp: "RLP substituted in #{__MODULE__}!"}}
  end

  def create(_parent, args, _resolution) do
    agent_rlp = Crypto.from_hex(args.agent)
    %Tx{
      type: :create,
      from: args.address,
      data: [agent_rlp, args.params]
    }
    |> TransactionController.send()
    |> case do
      {:ok, response} ->
        {:ok, %{
          hash:   response["hash"],
          height: response["height"],
          data:   response["deliver_tx"]["data"]
        }}
      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  def mint(_parent, args, _resolution) do
    %Tx{
      type: :transfer,
      to: args.to,
      from: "0x",
      value: args.value
    }
    |> TransactionController.send()
    {:ok, %{rlp: "RLP substituted in #{__MODULE__}!"}}
  end

  def transfer(_parent, args, _resolution) do
    %Tx{
      type: :transfer,
      to: args.to,
      from: args.from,
      value: args.value
    }
    |> TransactionController.send()
    {:ok, %{rlp: "RLP substituted in #{__MODULE__}!"}}
  end

  @doc """
  Creates and sends a transaction to forward the message to the agent

  ## Arguments
    - args.to:      Address of receiving agent
    - args.from:    Address of sending agent
    - args.message: Structure of the message encoded by RLP
  """
  def send_msg(_parent, args, _resolution) do
    msg_rlp = Crypto.from_hex(args.message)
    %Tx{type: :send, to: args.to, data: msg_rlp}
    |> TransactionController.send()
    |> case do
      {:ok, response} ->
        {:ok, %{
          hash:   response["hash"],
          height: response["height"],
          data:   response["deliver_tx"]["data"]
        }}
      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end

  @doc """
  Checks transaction presence in blockchain

  ## Arguments
    - args.hash:  Transaction hash
  """
  def check_tx(_parent, args, _resolution) do
    case TransactionController.check(args.hash) do
      {:ok, response} ->
        {:ok, %{
          hash: response["hash"],
          height: response["height"],
        }}
      {:error, {_, reason, description}} ->
        {:error, reason <> ": " <> description}
    end
  end

  def bid(_parent, args, _resolution) do
    bid_rlp = Crypto.from_hex(args.bid)
    %Tx{type: :bid, from: args.from, data: bid_rlp}
    |> TransactionController.send()
    |> case do
      {:ok, response} ->
        {:ok, %{
          hash: response["hash"],
          height: response["height"],
        }}
      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end
end
