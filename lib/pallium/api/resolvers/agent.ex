defmodule Pallium.Api.Resolvers.Agent do
  alias Pallium.Core.Agent

  def new(_parent, args, _resolution) do
    {:ok, %{rlp: Agent.new(args.code)}}
  end

  def get_agent(_parent, args, _resolution) do
    {:ok, %{address: args.address, balance: 1, }}
  end
end
