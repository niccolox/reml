defmodule Reml.Examples.Pipelines.Trainer.Fit do
  @moduledoc """
  Fit model
  """
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, [])
  end

  def init(state) do
    {:consumer, state}
  end

  def handle_events({x,y}, _from, state) do
    
    {:noreply, [], state}
  end
end
