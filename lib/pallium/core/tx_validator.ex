defmodule Pallium.Core.TxValidator do
  alias Pallium.Core.Store

  def validate(%{type: :send} = tx) do
    ensure_agent_exists(tx.to)
  end

  def validate(%{type: :bid} = tx) do
    ensure_agent_exists(tx.from)
  end

  def validate(_), do: :ok

  defp ensure_agent_exists(address) do
    case Store.get(address) do
      nil -> {:agent_missing, address}
      _ -> :ok
    end
  end
end
