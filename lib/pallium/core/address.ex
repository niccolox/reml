defmodule Pallium.Core.Address do
  @type key :: binary
  @type address :: <<_::160>>

  @spec new(key()) :: address()
  def new(public_key) do
    public_key |> Helpers.keccak()
  end
end