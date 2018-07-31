defmodule Pallium.Api.Schema.AgentTypes do
  use Absinthe.Schema.Notation

  object :agent do
    field :address, :string
    field :balance, :integer
  end
end
