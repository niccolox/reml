defmodule Reml.App.Task.BidStorage do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_bid(bid) do
    Agent.update(__MODULE__, &[bid | &1])
  end

  def get_all do
    Agent.get(__MODULE__, &(&1))
  end

  def delete_bid(bid) do
    Agent.get_and_update(__MODULE__, fn bids ->
      bids
      |> Enum.find_index(&(&1 == bid))
      |> case do
        nil -> {false, bids}
        i -> {true, List.delete_at(bids, i)}
      end
    end)
  end

  def has_bid?(bid) do
    Agent.get(__MODULE__, fn bids -> Enum.any?(bids, &(&1 == bid)) end)
  end
end
