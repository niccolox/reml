defmodule Reml.App.Pipeline.Consumer do
  use GenStage

  require Logger

  def start_link do
    GenStage.start_link(__MODULE__, [])
  end

  def init([]) do
    {:consumer, :state}
  end

  def handle_events([res], _from, :state) do
    Logger.warn("PIPELINE RESULT: #{inspect res}")
    {:noreply, [], :state}
  end
end
