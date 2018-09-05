defmodule Pallium.Core.Agent do
  @moduledoc """
  Documentation for Pallium Autonomous Intelligent Agents.
  """
  alias MerklePatriciaTree.Trie
  alias Pallium.Core.{Bid, Message, Store}
  alias Pallium.Env
  alias Pallium.App.Exchange

  @empty_trie MerklePatriciaTree.Trie.empty_trie_root_hash()

  defstruct nonce: 0,
            balance: 0,
            state: @empty_trie,
            code: <<>>

  @type agent :: %__MODULE__{
          nonce: integer(),
          balance: integer(),
          state: Core.trie_root(),
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
  @doc """
  Creates an agent struct

  Return: Hex string with RLP encoded agent struct

  ## Arguments
    - code: Hex string with code of agent
  """
  def new(code \\ <<>>) do
    %__MODULE__{code: code |> Helpers.from_hex()}
    |> serialize()
    |> ExRLP.encode(encoding: :hex)
  end

  @doc """
  Creates a new entry in the Store with an agent structure and execute construct
  function in agent code

  ## Arguments
    - agent_rlp: Hex string with RLP encoded agent struct
    - address: Address of agent
  """
  def create(address, agent_hex_rlp, params) do
    with :ok <- Store.update(address, agent_hex_rlp |> Helpers.from_hex),
         {:ok, _} <- dispatch(address, :construct, params),
         do: {:ok, address}
  end

  @doc """
  Get agent struct from Store

  Return: Agent struct

  ## Arguments
    - address: Address of agent
  """
  def get_agent(address) do
    case Store.get(address) do
      nil -> nil
      <<>> -> nil
      agent -> agent |> ExRLP.decode() |> deserialize()
    end
  end

  def send(address, rlp_msg) do
    message = Message.decode(rlp_msg)
    dispatch(address, :message, %{action: message.action, data: message.props})
  end

  def dispatch(address, method, data \\ <<>>) do
    with agent <- get_agent(address),
         state <- agent.state do
      if agent.code != <<>> do
        address
        |> Env.deploy_agent(agent.code)
        |> Env.dispatch(state, address, method, data)
      end
    end
  end

  def transfer(to, from, value) do
    from_agent = get_agent(from)

    cond do
      from == "0x" ->
        to |> get_agent() |> do_transfer(to, value)

      from_agent == nil ->
        {:reject, "sender account does not exist"}

      from_agent.balance < value ->
        {:reject, "sender account insufficient funds"}

      true ->
        (fn ->
           to |> get_agent() |> do_transfer(to, value)
           from_agent |> do_transfer(from, -1 * value)
         end).()
    end
  end

  defp do_transfer(agent, address, value) do
    agent
    |> update_balance(agent.balance + value)
    |> increment_nonce()
    |> (fn next -> next |> commit(address) end).()
  end

  def get_balance(address) do
    case get_agent(address) do
      nil -> nil
      agent -> {:ok, agent.balance}
    end
  end

  def put_state(address, key, value) do
    case get_agent(address) do
      nil -> nil
      agent ->
        updated_storage_trie = update_state(agent.state, key, value)
        agent |> update_state(updated_storage_trie.root_hash) |> commit(address)
    end
  end

  defp update_state(root, key, value) do
    root
    |> store_trie()
    |> Trie.update(key |> Helpers.keccak(), value |> ExRLP.encode())
  end

  def get_state_value(address, key) do
    case get_agent(address) do
      nil -> nil
      agent -> state_fetch(agent.state, key)
    end
  end

  def set_state(address, state) do
    Enum.each(state, fn {key, value} ->
      put_state(address, Atom.to_string(key), value)
    end)
  end

  def set_state_root_hash(address, hash) do
    case get_agent(address) do
      nil -> nil
      agent ->
        agent
        |> update_state(hash)
        |> commit(address)
    end
  end

  def bid(address, data) do
    case get_agent(address) do
      nil -> {:error, :no_agent}
      _agent ->
        data
        |> Bid.deserialize()
        |> Exchange.bid(address)
        :ok
    end
  end

  defp store_trie(root), do: Store.get().db |> Trie.new(root)

  defp state_fetch(root, key) do
    root
    |> store_trie()
    |> Trie.get(key |> Helpers.keccak())
    |> ExRLP.decode()
  end

  defp increment_nonce(agent) do
    %__MODULE__{agent | nonce: agent.nonce + 1}
  end

  defp update_balance(agent, value) do
    %__MODULE__{agent | balance: value}
  end

  defp update_state(agent, value) do
    %__MODULE__{agent | state: value}
  end

  defp commit(next_agent, address) do
    Store.update(address, next_agent |> serialize() |> ExRLP.encode())
  end
end
