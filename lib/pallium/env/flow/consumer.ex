defmodule Pallium.Env.Flow.Consumer do
  @moduledoc false
  use GenStage
  
  alias Pallium.Env.Flow.Producer

  def start_link(size) do
    GenStage.start_link(__MODULE__, %{size: size, producers: [], sum: []})
  end
  
  def init(state) do
   {:consumer, state}
  end

  def handle_events([:hello], from, state) do
    {pid, _} = from 
    IO.puts("Hello i'am: #{inspect length(state.producers)}")
    next_state = %{state | producers: state.producers ++ [pid]}
    if length(state.producers) == state.size do
      Enum.each(state.producers, fn p -> Producer.add(p, 2, 2) end)
    end 
    {:noreply, [], next_state}
  end

  def handle_events([[add: result]], _from, state) do
    IO.puts("Event result: #{result}")
    next_state = %{state | sum: state.sum ++ [result]}
    IO.puts("Event sum: #{inspect next_state.sum}")

    if length(next_state.sum) == state.size do
      sum = Enum.reduce(next_state.sum, 0, fn x, acc -> x + acc end)
      IO.puts("Reduce result: #{sum}")
    end
    
    {:noreply, [], next_state}
  end
end
