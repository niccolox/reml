defmodule Pallium.Api.Schema do
  use Absinthe.Schema
  import_types Pallium.Api.Schema.AgentTypes

  alias Pallium.Api.Resolvers

  query do

    @desc "Get agent"
    field :agent, :agent do
      arg :address, non_null(:string)
      resolve &Resolvers.Agent.get_balance/3
    end

  end

end
