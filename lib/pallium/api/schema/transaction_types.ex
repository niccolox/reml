defmodule Pallium.Api.Schema.TransactionTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :tx do
    field :rlp, :string
  end
end
