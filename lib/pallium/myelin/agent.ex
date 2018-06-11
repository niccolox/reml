defmodule Pallium.Myelin.Agent do
  @moduledoc """
  Documentation for Pallium Autonomous Intelligent Agents.
  """
  alias Pallium.Myelin.Store
  alias Pallium.Env

  @empty_keccak Helpers.keccak(<<>>)
  # @empty_trie MerklePatriciaTree.Trie.empty_trie_root_hash

  defstruct nonce: 0,
            balance: 0,
            state: @empty_keccak,
            code: <<>>

  @type agent :: %__MODULE__{
          nonce: integer(),
          balance: integer(),
          state: Myelin.trie_root(),
          code: binary()
        }

  @spec serialize(agent) :: ExRLP.t()
  def serialize(agent) do
    [
      agent.nonce,
      agent.balance,
      agent.state,
      agent.code
    ]
  end

  @spec deserialize(ExRLP.t()) :: agent
  def deserialize(rlp) do
    [
      nonce,
      balance,
      state,
      code
    ] = rlp

    %__MODULE__{
      nonce: :binary.decode_unsigned(nonce),
      balance: :binary.decode_unsigned(balance),
      state: state,
      code: code
    }
  end

  # @spec(binary()) :: agent()
  def new(code) do
    %__MODULE__{%Pallium.Myelin.Agent{} | code: code} |> serialize() |> ExRLP.encode()
  end
  
  def put(agent_rlp, address) do
    Store.update(address, agent_rlp)
    {:ok, address}
  end

  def dispatch(address, data) do
    agent = get_agent(address)
    Env.deploy_agent(address, agent.code)
  end

  def transfer(to, from, value) when from != "0x" do
    recipient = get_agent(to)
    sender = get_agent(from)

    if sender.balance - value > 0 do
      do_transfer(sender, from, sender.balance - value, sender.nonce + 1)
      do_transfer(recipient, to, recipient.balance + value, recipient.nonce + 1)
      {:ok, ""}
    else
      {:reject, "Insufficient funds"}
    end
  end

  def transfer(to, from, value) when from == "0x" do
    recipient = get_agent(to)
    recipient |> do_transfer(to, recipient.balance + value, recipient.nonce + 1)
  end

  defp do_transfer(agent, address, next_balance, next_nonce) do
    agent
    |> update_balance(next_balance)
    |> update_nonce(next_nonce)
    |> (fn next -> next |> serialize() |> ExRLP.encode() |> put(address) end).()
  end

  defp update_balance(agent, value) do
    %__MODULE__{agent | balance: value}
  end

  defp update_nonce(agent, value) do
    %__MODULE__{agent | nonce: value}
  end

  def get_balance(address) do
    case get_agent(address) do
      nil -> nil
      <<>> -> nil
      agent -> {:ok, agent.balance}
    end
  end

  def get_agent(address) do
    case Store.get(address) do
      nil -> nil
      <<>> -> nil
      agent -> agent |> ExRLP.decode() |> deserialize()
    end
  end
end
