defmodule Pallium.Core.Bid do
  @moduledoc """
    Propose of computation resources
  """

  @fields ~w(ip net cluster device_name device_type memory_limit)a

  def serialize(bid) do
    Enum.map(@fields, &Map.get(bid, &1))
  end

  def deserialize(rlp) do
    Enum.zip(@fields, rlp)
  end
end
