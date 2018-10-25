defmodule Reml.Api.Schema.TransactionTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :tx do
    field :hash, :string
    field :height, :integer
    field :data, :string
  end
end
