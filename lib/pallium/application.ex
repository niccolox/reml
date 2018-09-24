defmodule Pallium.Application do
  @moduledoc false

  alias Pallium.Api.Server
  alias Pallium.App
  alias Pallium.App.Task.BidStorage
  alias Pallium.App.Task.TaskStorage
  alias Pallium.App.Task.ConfirmationStorage
  alias Pallium.App.State
  alias Pallium.App.Store

  alias Pallium.Tendermint.Node

  alias MerklePatriciaTree.{Test, Trie}

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: AgentProcessSupervisor},
      {Store, store_trie()},
      BidStorage,
      TaskStorage,
      ConfirmationStorage,
      State,
      {ABCI, App},
      Server,
      Node,
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp store_trie do
    Test.random_ets_db() |> Trie.new()
  end
end
