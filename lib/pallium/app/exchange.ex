defmodule Pallium.App.Exchange do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: Exchange)
  end

  def init(state), do: {:ok, state}

  def add_bid(bid) do
    GenServer.cast(Exchange, {:add_bid, bid})
  end

  def get_bids do
    GenServer.call(Exchange, :get_bids)
  end

  # callbacks

  def handle_cast({:add_bid, bid}, state) do
    {:noreply, [bid | state]}
  end

  def handle_call(:get_bids, _from, state) do
    {:reply, state, state}
  end
end
