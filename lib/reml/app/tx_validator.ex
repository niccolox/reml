defmodule Reml.App.TxValidator do
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Core.Bid
  alias Reml.App.Store
  alias Reml.App.Task.BidStorage

  def validate(%Tx{type: :send} = tx) do
    ensure_agent_exists(tx.to)
  end

  def validate(%Tx{type: :bid} = tx) do
    ensure_agent_exists(tx.from)
  end

  def validate(%Tx{type: :confirm} = tx) do
    [bid_rlp, _] = tx.data
    bid = Bid.decode(bid_rlp)
    case BidStorage.has_bid?(bid) do
      true -> :ok
      false -> {:bid_not_found, bid}
    end
  end

  def validate(%Tx{}), do: :ok

  defp ensure_agent_exists(address) do
    case Store.get_agent(address) do
      nil -> {:agent_missing, address}
      _ -> :ok
    end
  end
end
