defmodule Reml.App.Pipeline.Consumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, [])
  end

  def init([]) do
    {:consumer, :state}
  end

  def handle_events(events, from, :state) do
    IO.inspect(events, label: "Consuming events from #{inspect from}")
    {:noreply, [], :state}
  end
end
