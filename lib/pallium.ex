defmodule Pallium do
  @moduledoc """
  Documentation for Pallium.
  """
  alias Pallium.Api.Server
  alias Pallium.App

  @type key :: binary
  @type address :: <<_::160>>

  def start do
    App.init()
    Server.start_link()
  end
end
