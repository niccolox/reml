defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Core.Store

  @type key :: binary
  @type address :: <<_::160>>

  def start do
    Test.random_ets_db() |> Trie.new() |> Store.start_link()
    App.init()
    Server.start_link()
  end
end
