defmodule Pallium.Api.Resolvers.Agent do

  def get_balance(_parent, args, _resolution) do
    {:ok, %{address: args.address, balance: 1, }}
  end

end
