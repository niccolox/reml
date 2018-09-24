defmodule Pallium.App.Task.BidStorage do
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
end
