defmodule Pallium.Api.Resolvers.Tendermint do
  @moduledoc false

  alias Pallium.Tendermint.Node

  def pub_key(_parent, _args, _resolution) do
    pub_key = Node.pub_key()

    {:ok, %{type: pub_key["type"], value: pub_key["value"]}}
  end
end
