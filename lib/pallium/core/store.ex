defmodule Pallium.Core.Store do
  use GenServer

  def init(trie), do: {:ok, trie}

  def handle_call(:get, _from, trie), do: {:reply, trie, trie}

  def handle_call({:get, key}, _from, trie) do
    {:reply, MerklePatriciaTree.Trie.get(trie, key), trie}
  end

  def handle_cast({:update, key, value}, trie) do
    {:noreply, trie |> MerklePatriciaTree.Trie.update(key, value)}
  end

  def start_link() do
    trie = MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new()
    GenServer.start_link(__MODULE__, trie, name: __MODULE__)
  end

  def start_link(trie) do
    GenServer.start_link(__MODULE__, trie, name: __MODULE__)
  end

  def get, do: GenServer.call(__MODULE__, :get)
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def update(key, value), do: GenServer.cast(__MODULE__, {:update, key, value})
end