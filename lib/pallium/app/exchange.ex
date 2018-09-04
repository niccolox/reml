defmodule Pallium.App.Exchange do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: Exchange)
  end

  def init(state), do: {:ok, state}

  def bid(bid, address) do
    GenServer.cast(Exchange, {:bid, bid, address})
  end

  # callbacks

  def handle_cast({:bid, bid, address}, state) do
    {:noreply, [{bid, address} | state]}
  end
end
