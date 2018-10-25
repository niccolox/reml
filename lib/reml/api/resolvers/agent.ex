defmodule Reml.Api.Resolvers.Agent do
  @moduledoc false

  alias PalliumCore.Core.Agent

  def new(_parent, args, _resolution) do
    rlp =
      %Agent{code: args.code, key: args.key}
      |> Agent.encode()

    {:ok, %{rlp: rlp}}
  end

  def get_agent(_parent, args, _resolution) do
    {:ok, %{address: args.address, balance: 1}}
  end
end
