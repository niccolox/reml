defmodule Pallium.Api.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias Pallium.Api.Resolvers.{Agent, Transaction}

  import_types Pallium.Api.Schema.AgentTypes
  import_types Pallium.Api.Schema.TransactionTypes

  query do
    @desc "Get agent"
    field :get_agent, :agent do
      arg :address, non_null(:string)

      resolve &Agent.get_agent/3
    end

    @desc "New agent"
    field :new_agent, :agent_rlp do
        arg :code, :string
        resolve &Agent.new/3
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

      resolve &Transaction.send/3
    end
  end
end
