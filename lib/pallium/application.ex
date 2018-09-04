defmodule Pallium.Application do
  @moduledoc false

  alias Pallium.App.Exchange
  alias Pallium.Core.Store
  alias MerklePatriciaTree.{Test, Trie}

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: AgentProcessSupervisor},
      {Store, store_trie()},
      Exchange,
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp store_trie do
    Test.random_ets_db() |> Trie.new()
  end
end
