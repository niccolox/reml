defmodule Pallium.Api.Schema.MessageTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :message_rlp do
    field :rlp, :string
  end
end
