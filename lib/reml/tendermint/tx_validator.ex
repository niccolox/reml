defmodule Reml.Tendermint.TxValidator do
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Core.Bid
  alias Reml.App.Store
  alias Reml.App.Task.BidStorage

  def validate_tx(%Tx{type: type} = tx), do: validate(type, tx)

  defp validate(:send, tx) do
    ensure_agent_exists(tx.to)
  end

  defp validate(:bid, tx) do
    ensure_agent_exists(tx.from)
  end

  defp validate(:confirm, %Tx{data: [bid_rlp, _]}) do
    bid = Bid.decode(bid_rlp)
    case BidStorage.has_bid?(bid) do
      true -> :ok
      false -> {:error, {:bid_not_found, "Bid does not exist or already assigned"}}
    end
  end

  defp validate(_, %Tx{}), do: :ok

  defp ensure_agent_exists(address) do
    case Store.get_agent(address) do
      nil -> {:error, {:agent_not_found, "Agent #{address} does not exist"}}
      _ -> :ok
    end
  end
end
