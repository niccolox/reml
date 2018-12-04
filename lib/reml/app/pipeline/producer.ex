defmodule Reml.App.Pipeline.Producer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, [])
  end

  def init([]) do
    {:producer, :state}
  end

  def handle_demand(demand, :state) do
    IO.inspect(demand, label: "Demanded")
    {:noreply, [], :state}
  end

  def handle_cast({:run, data}, state) do
    {:noreply, [data], state}
  end
end
