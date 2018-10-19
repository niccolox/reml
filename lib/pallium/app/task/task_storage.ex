defmodule Pallium.App.Task.TaskStorage do
  use Agent

  alias Pallium.App.Task

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_task(task) do
    Agent.update(__MODULE__, &[task | &1])
  end

  def find_by_status(status) do
    Agent.get(__MODULE__, fn tasks -> Enum.filter(tasks, &(&1.status == status)) end)
  end

  def assign(task) do
    Agent.update(__MODULE__, &mark_assigned(&1, task))
  end

  # private

  defp mark_assigned(tasks, task) when is_list(tasks) do
    Enum.map(tasks, &mark_assigned(&1, task))
  end

  defp mark_assigned(%Task{} = task, task), do: %Task{task | status: :assigned}

  defp mark_assigned(%Task{} = task, %Task{}), do: task
end
