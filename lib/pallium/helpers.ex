defmodule Helpers do
  @moduledoc """
  Helpers for common operations
  """
  @type keccak_hash :: binary()

  @spec keccak(binary()) :: keccak_hash
  def keccak(data), do: :keccakf1600.sha3_256(data)

  @spec from_hex(String.t()) :: binary()
  def from_hex(hex_data), do: Base.decode16!(hex_data, case: :lower)

  @spec to_hex(binary()) :: String.t()
  def to_hex(bin), do: Base.encode16(bin, case: :lower)
end
