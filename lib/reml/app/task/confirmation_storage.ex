defmodule Reml.App.Task.ConfirmationStorage do
  use Agent

  require Logger

  alias PalliumCore.Core.Ask
  alias Reml.App.Task

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add_confirmation(task, bid) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, task, [bid], &[bid | &1])
    end)
  end

  def get_workers(task) do
    ask = Task.ask(task)
    Agent.get(__MODULE__, fn state -> state[task] end)
    |> group(ask)
    |> find_satisfied(ask.num_devices)
  end

  defp group(bids, %Ask{same_node: true}), do: group_by(bids, [:cluster_id, :node_id])

  defp group(bids, %Ask{same_node: false, same_cluster: true}), do: group_by(bids, [:cluster_id])

  defp group(bids, %Ask{same_node: false, same_cluster: false}), do: [bids]

  defp group_by(bids, keys) do
    bids
    |> Enum.group_by(fn bid -> Enum.map(keys, &Map.fetch!(bid, &1)) end)
    |> Map.values()
  end

  defp find_satisfied(grouped_bids, num_bids) do
    case Enum.filter(grouped_bids, &(length(&1) >= num_bids)) do
      [bids] -> bids
      [] -> nil
      [bids | _] -> Logger.warn("More than 1 group of bids satisfying task"); bids
    end
  end
end
