defmodule Pallium.Api.Schema.TendermintTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :key do
    field :type, :string
    field :value, :string
  end
end
