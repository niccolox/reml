defmodule Pallium.Api.Server do
  @moduledoc false

  alias Pallium.Api.Server
  alias Plug.Adapters.Cowboy2

  use Plug.Router

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug Absinthe.Plug,
    schema: Pallium.Api.Schema

  forward "/api",
    to: Absinthe.Plug,
    init_opts: [schema: Pallium.Api.Schema]

  def start_link do
    {:ok, _} = Cowboy2.http(Server, [], port: 8787)
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
    }
  end
end
