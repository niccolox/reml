defmodule Pallium.Api.Schema do
  use Absinthe.Schema
  import_types Pallium.Api.Schema.AgentTypes
  import_types Pallium.Api.Schema.TransactionTypes

  alias Pallium.Api.Resolvers

  query do
    @desc "Get agent"
    field :get_agent, :agent do
      arg :address, non_null(:string)

      resolve &Resolvers.Agent.get_agent/3
    end

    @desc "New agent"
    field :new_agent, :agent_rlp do
        arg :code, :string
        resolve &Resolvers.Agent.new/3
    end
  end

  mutation do
    @desc "Send a transaction"
    field :send_tx, type: :tx do
      arg :type, non_null(:string)
      arg :to, non_null(:string)
      arg :from, :string
      arg :value, :integer
      arg :data, :string
      arg :sign, :string

      resolve &Resolvers.Transaction.send/3
    end
  end
end
