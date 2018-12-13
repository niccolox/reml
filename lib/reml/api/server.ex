defmodule Reml.Api.Server do
  @moduledoc false

  alias Reml.Api.Server
  alias Plug.Cowboy

  use Plug.Router

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug Absinthe.Plug,
    schema: Reml.Api.Schema

  forward "/api",
    to: Absinthe.Plug,
    init_opts: [schema: Reml.Api.Schema]

  def start_link do
    {:ok, _} = Cowboy.http(Server, [], port: 8080)
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
    }
  end
end
