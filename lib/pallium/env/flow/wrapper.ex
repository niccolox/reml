defmodule Pallium.Env.Flow.Wrapper do
  @moduledoc false
  use GenServer

  def start_link() do
    state = %{workers: [], rank: 0, }
    GenServer.start_link(__MODULE__, state)
  end  

  def start_link(host) do
    state = __MODULE__.get_state(host) 
    rank = length(state.workers) + 1 

    next_state = %{state | workers: [host | state.workers], rank: rank }  
    
    {:ok, pid} = GenServer.start_link(__MODULE__, next_state)
    Enum.each(next_state.workers, fn w -> __MODULE__.register(w, pid) end)
    
    {:ok, pid}
  end  
  
  def register(pid, worker) do
    GenServer.cast(pid, {:register, worker})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end  
 
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:register, worker}, state) do
    {:noreply, %{state | workers: state.workers ++ [worker]}}
  end  

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  #def init(task, size) do
  #  listen(task, 0, size, [])
  #end

  #def init(task, size, host_pid) do
  #  [workers, rank] = send host_pid, {:connect, self()}
  #  listen(task, nil, size, [host_pid])
  #end  
 #
  #def listen(task, rank, size, workers) do
  #  receive do
  #    :run -> IO.inspect(task.())
  #    {:connect, pid} when  -> 
  #      fn -> send pid, {:connect, [length(workers)+1, workers]}
  #                             workers = [pid | workers]
  #                       end
  #    {:connect, [r, w]} -> fn -> rank = r
  #                                workers = [w | workers]
  #                         end
  #    :get -> IO.inspect(workers)
  #  end
  #    listen(task, rank, size, workers)  
  #end 
end
