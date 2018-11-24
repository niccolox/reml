defmodule Reml.Application do
  @moduledoc false

  alias Reml.Api.Server
  alias Reml.App
  alias Reml.App.Task.BidStorage
  alias Reml.App.Task.TaskStorage
  alias Reml.App.Task.ConfirmationStorage
  alias Reml.App.State
  alias Reml.App.Store

  alias Reml.Tendermint.TMNode

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
      TMNode,
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp store_trie do
    Test.random_ets_db() |> Trie.new()
  end
end
