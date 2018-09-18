defmodule Pallium.App.Allocator do
  @moduledoc "Allocates tasks"

  alias PalliumCore.Core.Ask
  alias PalliumCore.Core.Bid
  alias Pallium.App.Allocator.Rate

  @doc """
  Returns list of batches, each batch is a list of bids, suitable for responding
  to given ask on specific iteration
  """
  def allocate(ask, bids, iteration), do: allocate(ask, bids) |> Enum.at(iteration)

  def allocate(ask, bids) do
    bids
    |> Enum.map(&{&1, Rate.rate(ask, &1)})
    |> Enum.reject(fn {_bid, rate} -> rate == 0 end)
    |> group(ask)
    |> Enum.reject(fn rated_bids -> length(rated_bids) < ask.num_devices end)
    |> Enum.map(&make_batches(&1, ask.num_devices))
    |> List.flatten()
    |> Enum.sort_by(fn {rate, _batch} -> rate end)
    |> Enum.chunk_by(fn {rate, _batch} -> rate end)
    |> Enum.map(fn rated_batches ->
      rated_batches |> Enum.map(fn {_rate, batch} -> batch end) |> List.flatten()
    end)
  end

  @doc """
  Groups rated bids (i.e. pairs {bid, rate}) by ask's demand (same cluster/same node/global)
  """
  defp group(rated_bids, %Ask{same_node: true}), do: group_by(rated_bids, [:cluster_id, :node_id])

  defp group(rated_bids, %Ask{same_node: false, same_cluster: true}), do: group_by(rated_bids, [:cluster_id])

  defp group(rated_bids, %Ask{same_node: false, same_cluster: false}), do: [rated_bids]

  defp group_by(rated_bids, keys) do
    rated_bids
    |> Enum.group_by(fn {bid, _rate} -> Enum.map(keys, &Map.fetch!(bid, &1)) end)
    |> Map.values()
  end

  @doc """
  Splits list of rated bids into batches. First batch should include enough bids for satisfying
  the ask's num_device demand. Subsequent batches used to expand set of allowed bids on next
  iterations in case some of bids will not confirm readiness at their iterations
  """
  defp make_batches(rated_bids, min_first_batch) do
    rated_bids
    |> Enum.group_by(fn {_bid, rate} -> rate end, fn {bid, _rate} -> bid end)
    |> Map.to_list()
    |> Enum.sort_by(fn {rate, _bids} -> rate end)
    |> complect_first_batch(min_first_batch)
  end

  defp complect_first_batch([{_rate, bids} | _] = list, num) when length(bids) >= num, do: list

  defp complect_first_batch([{rate1, bids1}, {rate2, bids2} | t], num) when rate1 < rate2 do
    complect_first_batch([{rate2, bids1 ++ bids2} | t], num)
  end
end
