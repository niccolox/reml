defmodule Pallium.Env.Flow.Consumer do
  @moduledoc false
  use GenStage
  
  alias Pallium.Env.Flow.Producer

  def start_link(size) do
    GenStage.start_link(__MODULE__, %{size: size, producers: []})
  end
  
  def init(state) do
   {:consumer, state}
  end

  def handle_events([:hello], from, state) do
    {pid, _} = from 
    IO.puts("Hello i'am: #{inspect length(state.producers)}")
    next_state = %{state | producers: state.producers ++ [pid]}
    if length(next_state.producers) == state.size do
      Enum.each(next_state.producers, fn p -> Producer.train(p, 2, 2) end)
    end 
    {:noreply, [], next_state}
  end

  def handle_events([[train: result]], _from, state) do
    IO.puts("Train finished on: #{result}")
    {:noreply, [], state}
  end
end
