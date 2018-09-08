defmodule Pallium.Core.TxValidator do
  alias Pallium.Core.Store
  alias PalliumCore.Core.Transaction, as: Tx

  def validate(%Tx{type: :send} = tx) do
    ensure_agent_exists(tx.to)
  end

  def validate(%Tx{type: :bid} = tx) do
    ensure_agent_exists(tx.from)
  end

  def validate(%Tx{}), do: :ok

  defp ensure_agent_exists(address) do
    case Store.get(address) do
      nil -> {:agent_missing, address}
      _ -> :ok
    end
  end
end