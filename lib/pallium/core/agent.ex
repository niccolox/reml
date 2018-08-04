defmodule Pallium.Core.Agent do
  @moduledoc """
  Documentation for Pallium Autonomous Intelligent Agents.
  """
  alias MerklePatriciaTree.Trie
  alias Pallium.Core.{Agent,Message,Store}
  alias Pallium.Env

  @empty_keccak Helpers.keccak(<<>>)
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

  # @spec(binary()) :: agent()
  def new(code) do
    %__MODULE__{%Agent{} | code: code |> Helpers.from_hex()} |> serialize() |> ExRLP.encode(encoding: :hex)
  end

  def create(agent_rlp, address) do
    agent = agent_rlp |> put(address)

    case agent do
      {:ok, address} -> dispatch(address, :construct)
      {:reject, reason} -> {:reject, reason}
    end
  end

  def put(agent_rlp, address) do
    Store.update(address, agent_rlp)
    {:ok, address}
  end

  def get_agent(address) do
    case Store.get(address) do
      nil -> nil
      <<>> -> nil
      agent -> agent |> ExRLP.decode() |> deserialize()
    end
  end

  def send(address, rlp_msg) do
    message = Message.decode(rlp_msg)
    dispatch(address, :message , %{action: message.action, data: message.data})
  end

  def dispatch(address, method, data \\ <<>>) do
    with agent <- get_agent(address),
         state <- agent.state do
      if agent.code != <<>> do
        Env.deploy_agent(address, agent.code) |> Env.dispatch(state, address, method, data)
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
      nil ->
        nil

      agent ->
        (fn ->
           updated_storage_trie = state_update(agent.state, key, value)
           agent |> update_state(updated_storage_trie.root_hash) |> commit(address)
         end).()
    end
  end

  defp state_update(root, key, value) do
    store = Store.get()

    Trie.new(store.db, root)
    |> Trie.update(key |> Helpers.keccak(), value |> ExRLP.encode())
  end

  def get_state(address, key) do
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

  defp state_fetch(root, key) do
    store = Store.get()
    Trie.new(store.db, root) |> Trie.get(key |> Helpers.keccak()) |> ExRLP.decode()
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
    next_agent |> serialize() |> ExRLP.encode() |> put(address)
  end
end
