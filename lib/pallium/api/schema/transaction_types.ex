defmodule Pallium.Api.Schema.TransactionTypes do
  use Absinthe.Schema.Notation

  object :tx do
    field :rlp, :string
  end
end
