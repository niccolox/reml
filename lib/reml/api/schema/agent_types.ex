defmodule Reml.Api.Schema.AgentTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :agent do
    field :address, :string
    field :nonce, :integer
    field :balance, :integer
    field :state, :string
    field :code, :string
  end

  object :agent_rlp do
    field :rlp, :string
  end
end
