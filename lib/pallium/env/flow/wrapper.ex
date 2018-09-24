defmodule Pallium.Env.Flow.Wrapper do
  @moduledoc false
  use GenStage

  def start_link(task) do
    state = %{task: task}
    GenStage.start_link(__MODULE__, state)
  end
  
  def push(pid, data) do
    GenStage.cast(pid, {:push, data})
  end  

  def init(state), do: {:producer, state}
  
  def handle_cast({:push, data}, state) do
    IO.puts("soso")
    events = state.task.([])
    {:noreply, ["soso"], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [:hello], state}
  end
end
