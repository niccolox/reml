defmodule Pallium.Application do
  @moduledoc false

  alias Pallium.Api.Server
  alias Pallium.App
  alias Pallium.App.Exchange
  alias Pallium.App.State
  alias Pallium.App.Store

  alias MerklePatriciaTree.{Test, Trie}

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: AgentProcessSupervisor},
      {Store, store_trie()},
      Exchange,
      State,
      {ABCI, App},
      Server,
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp store_trie do
    Test.random_ets_db() |> Trie.new()
  end
end
