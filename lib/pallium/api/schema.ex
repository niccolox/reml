defmodule Pallium.Api.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias Pallium.Api.Resolvers.{Agent, Transaction, Message}

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

    @desc "New message"
    field :new_message, :agent_rlp do
        arg :action, non_null(:string)
        arg :props, non_null(:string)
        resolve &Message.new/3
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

      resolve &Transaction.send_tx/3
    end

    @desc "Create agent"
    field :create, type: :tx do
      arg :address, non_null(:string)
      arg :agent, :string
      resolve &Transaction.create/3
    end

    @desc "Transfer of spike"
    field :transfer, type: :tx do
      arg :to, non_null(:string)
      arg :from, non_null(:string)
      arg :value, non_null(:integer)

      resolve &Transaction.transfer/3
    end

    @desc "Mint spike to agent"
    field :mint, type: :tx do
      arg :to, non_null(:string)
      arg :value, non_null(:integer)

      resolve &Transaction.mint/3
    end

    @desc "Send message to agent"
    field :send_msg, type: :tx do
      arg :to, non_null(:string)
      arg :from, :string
      arg :message, non_null(:string)

      resolve &Transaction.send_msg/3
    end

    @desc "Check transaction"
    field :check_tx, type: :tx do
      arg :hash, :string

      resolve &Transaction.check_tx/3
    end
  end
end
