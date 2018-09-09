defmodule Pallium.Core.Store do
  @moduledoc false

  use GenServer

  alias MerklePatriciaTree.Trie
  alias PalliumCore.Core.Agent

  def start_link(trie) do
    GenServer.start_link(__MODULE__, trie, name: Store)
  end

  def init(trie), do: {:ok, trie}

  def get_agent(address) do
    GenServer.call(Store, {:get_agent, address})
  end

  def update_agent(address, %Agent{} = agent) do
    GenServer.cast(Store, {:update_agent, address, agent})
  end

  def update_state_value(address, key, value) do
    GenServer.call(Store, {:update_state_value, address, key, value})
  end

  def update_state_value!(address, key, value) do
    case update_state_value(address, key, value) do
      :ok -> address
      {:error, reason} -> raise reason
    end
  end

  def reset_state_hash(address, state_hash) do
    GenServer.call(Store, {:reset_state_hash, address, state_hash})
  end

  def reset_state_hash!(address, state_hash) do
    case reset_state_hash(address, state_hash) do
      :ok -> address
      {:error, reason} -> raise reason
    end
  end

  def get_state_value(address, key) do
    GenServer.call(Store, {:get_state_value, address, key})
  end

  def get_state_value!(address, key) do
    case get_state_value(address, key) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  def set_state(address, map) do
    GenServer.call(Store, {:set_state, address, map})
  end

  def set_state!(address, map) do
    case set_state(address, map) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  # callbacks

  def handle_cast({:update_agent, address, agent}, trie) do
    {:noreply, save_agent(agent, trie, address)}
  end

  def handle_call({:get_agent, address}, _from, trie) do
    {:reply, fetch_agent(trie, address), trie}
  end

  def handle_call({:update_state_value, address, key, value}, _from, trie) do
    with_agent(trie, address, fn agent ->
      new_state =
        trie
        |> agent_trie(agent)
        |> put_value(key, value)
        |> Map.fetch!(:root_hash)

      new_trie =
        %Agent{agent | state: new_state}
        |> save_agent(trie, address)

      {:reply, :ok, new_trie}
    end)
  end

  def handle_call({:reset_state_hash, address, state_hash}, _from, trie) do
    with_agent(trie, address, fn agent ->
      new_trie =
        %Agent{agent | state: state_hash}
        |> save_agent(trie, address)

      {:reply, :ok, new_trie}
    end)
  end

  def handle_call({:get_state_value, address, key}, _from, trie) do
    with_agent(trie, address, fn agent ->
      value =
        trie
        |> agent_trie(agent)
        |> get_value(key)

      {:reply, {:ok, value}, trie}
    end)
  end

  def handle_call({:set_state, address, map}, _from, trie) do
    with_agent(trie, address, fn agent ->
      new_state =
        map
        |> Enum.reduce(
          agent_trie(trie, agent),
          fn {k, v}, t -> put_value(t, Atom.to_string(k), v) end
        )
        |> Map.fetch!(:root_hash)

      new_trie =
        %Agent{agent | state: new_state}
        |> save_agent(trie, address)

      {:reply, :ok, new_trie}
    end)
  end

  # private

  defp fetch_agent(trie, address) do
    case Trie.get(trie, address) do
      nil -> nil
      rlp -> Agent.decode(rlp)
    end
  end

  defp with_agent(trie, address, fun) do
    case fetch_agent(trie, address) do
      nil -> {:reply, {:error, "Agent not found"}, trie}
      %Agent{} = agent -> fun.(agent)
    end
  end

  defp agent_trie(trie, agent), do: Trie.new(trie.db, agent.state)

  defp save_agent(agent, trie, address) do
    Trie.update(trie, address, Agent.encode(agent))
  end

  defp put_value(trie, key, value) do
    Trie.update(trie, Helpers.keccak(key), ExRLP.encode(value))
  end

  defp get_value(trie, key) do
    case Trie.get(trie, Helpers.keccak(key)) do
      nil -> nil
      value -> value |> ExRLP.decode()
    end
  end
end
