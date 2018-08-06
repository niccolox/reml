defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Api.Server
  alias Pallium.App
  alias Pallium.Core.Store

  alias MerklePatriciaTree.Test
  alias MerklePatriciaTree.Trie

  @type key :: binary
  @type address :: <<_::160>>

  def start do
    Test.random_ets_db() |> Trie.new() |> Store.start_link()
    App.init()
    Server.start_link()
  end
end
