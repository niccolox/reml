defmodule Pallium.Api.Server do
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

  def start_link() do
    {:ok, _} = Plug.Adapters.Cowboy2.http(Pallium.Api.Server, [], port: 8080)
  end
end
