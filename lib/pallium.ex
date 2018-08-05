defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Core.Store

  @type key :: binary
  @type address :: <<_::160>>

  def start() do
    MerklePatriciaTree.Test.random_ets_db() |> MerklePatriciaTree.Trie.new() |> Store.start_link()
    Pallium.App.init()
    Pallium.Api.Server.start_link()
  end
end
