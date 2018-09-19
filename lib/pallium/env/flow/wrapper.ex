defmodule Pallium.Env.Flow.Wrapper do
  @moduledoc false
  use GenServer
  
  @initial_state %{workers: [], rank: 0, task: nil, size: 0, buffer: ""}
 
  def start_link(task, size) do
    state = %{@initial_state | task: task, size: size}
    GenServer.start_link(__MODULE__, state)
  end  

  def start_link(host) do
    GenServer.start_link(__MODULE__, host)
  end  
  
  def register(pid, worker) do
    GenServer.cast(pid, {:register, worker})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end
  
  def get_buffer(pid) do
    GenServer.call(pid, :get_buffer)
  end

  def push(pid, data) do
    GenServer.cast(pid, {:push, data})
  end
 
  def run(pid) do
    GenServer.call(pid, :run)
  end  

  def broadcast(pid, data) do
    GenServer.cast(pid, {:broadcast, data})
  end

  def init(state) when is_map(state) do
    {:ok, %{state | workers: [self()]}}
  end

  def init(host) when is_pid(host) do
    state = __MODULE__.get_state(host) 
    rank = length(state.workers) 

    next_state = %{state | rank: rank, workers: state.workers ++ [self()] }  

    Enum.each(state.workers, fn w -> __MODULE__.register(w, self()) end)

    if state.size == rank + 1 do
      IO.puts("Starting...")
      Enum.each(state.workers, fn w -> __MODULE__.run(w) end)
      pid = self()
      spawn fn-> state.task.(pid) end
    end  

    {:ok, next_state}
  end
  
  def handle_call(:run, _from, state) do 
    pid = self()
    spawn fn -> state.task.(pid) end
    {:reply, state, state}
  end

  def handle_cast({:broadcast, data}, state) do
    Process.sleep(100)
    Enum.each(tl(state.workers), fn w -> __MODULE__.push(w, data) end)
    {:noreply, %{state | buffer: data}}
  end
  
  def handle_cast({:register, worker}, state) do
    {:noreply, %{state | workers: state.workers ++ [worker]}}
  end  

  def handle_call(:get_state, _from, state), do: {:reply, state, state}
  def handle_call(:get_buffer, _from, state), do: {:reply, state.buffer, state.buffer}
  def handle_cast({:push, data}, state), do: {:noreply, %{state | buffer: data }} 
end
