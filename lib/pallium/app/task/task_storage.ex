defmodule Pallium.App.Task.TaskStorage do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_task(task) do
    Agent.update(__MODULE__, &[task | &1])
  end

  def find_by_status(status) do
    Agent.get(__MODULE__, fn tasks -> Enum.filter(tasks, &(&1.status == status)) end)
  end
end
