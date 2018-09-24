defmodule Pallium.Env.Flow.Consumer do
  @moduledoc false
  use GenStage

  def start_link(size) do
    GenStage.start_link(__MODULE__, %{size: size, producers: []})
  end
  
  def init(state) do
   {:consumer, state}
  end

  def handle_events(events, from, state) do
    IO.inspect from
    IO.inspect events
    {:noreply, [], state}
  end
end
