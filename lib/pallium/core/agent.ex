defmodule Pallium.Core.Agent do
  @moduledoc """
  Documentation for Pallium Autonomous Intelligent Agents.
  """
  alias MerklePatriciaTree.Trie
  alias Pallium.Core.Store
  alias Pallium.Env
  alias Pallium.App.Exchange
  alias PalliumCore.Core.{Agent, Bid, Message}
  alias PalliumCore.Crypto

  @doc """
  Creates a new entry in the Store with an agent structure and execute construct
  function in agent code

  ## Arguments
    - agent_rlp: Hex string with RLP encoded agent struct
    - address: Address of agent
  """
  def create(agent_hex_rlp, address, params) do
    with :ok <- Store.update(address, agent_hex_rlp |> Crypto.from_hex()),
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
      "" -> nil
      agent_rlp -> agent_rlp |> Agent.decode()
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
        with {:ok, module} <- Env.deploy_agent(address, agent.code) do
          Env.dispatch(module, state, address, method, data)
        end
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
    %Agent{agent | balance: agent.balance + value, nonce: agent.nonce + 1}
    |> commit(address)
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
        new_state = update_state(agent.state, key, value)
        %Agent{agent | state: new_state}
        |> commit(address)
    end
  end

  defp update_state(root, key, value) do
    root
    |> store_trie()
    |> Trie.update(Helpers.keccak(key), ExRLP.encode(value))
    |> Map.fetch!(:root_hash)
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
      nil ->
        nil

      agent ->
        %Agent{agent | state: hash}
        |> commit(address)
    end
  end

  def bid(address, data) do
    case get_agent(address) do
      nil ->
        {:error, :no_agent}

      _agent ->
        data
        |> Bid.decode()
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

  # defp increment_nonce(agent) do
  #   %__MODULE__{agent | nonce: agent.nonce + 1}
  # end

  # defp update_balance(agent, value) do
  #   %__MODULE__{agent | balance: value}
  # end

  # defp update_state(agent, value) do
  #   %__MODULE__{agent | state: value}
  # end

  defp commit(agent, address) do
    Store.update(address, Agent.encode(agent))
  end
end
