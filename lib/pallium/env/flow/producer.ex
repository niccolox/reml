defmodule Pallium.Env.Flow.Producer do
  @moduledoc false
  use GenStage

  def start_link() do
    state = []
    GenStage.start_link(__MODULE__, state)
  end
  
  def add(pid, x, y) do
    GenStage.cast(pid, {:push, x, y})
  end  

  def init(state), do: {:producer, state}
  
  def handle_cast({:push, x, y}, state) do
    events = [{:add, x+y}]
    {:noreply, [events], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [:hello], state}
  end
end
