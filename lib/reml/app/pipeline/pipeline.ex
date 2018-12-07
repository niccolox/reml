defmodule Reml.App.Pipeline do
  use GenServer

  alias Reml.App.Pipeline.Consumer
  alias Reml.App.Pipeline.Producer
  alias Reml.App.Task
  alias Reml.App.Task.TaskController
  alias Reml.Tendermint.TMNode

  def create(node, agents, pipeline_id) do
    tasks = create_tasks(agents, pipeline_id)
    case TMNode.address() do
      ^node -> start_link(tasks, pipeline_id)
      _ -> :ok
    end
  end

  def create_tasks(agents, pipeline_id) do
    Enum.map(agents, fn agent ->
      TaskController.add_task("", agent, "", pipeline_id)
    end)
  end

  def start_link(tasks, pipeline_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, tasks)
    IO.inspect(pipeline_id, label: "REGISTER PIPELINE AT #{inspect self()}")
    Registry.register(PipelineRegistry, pipeline_id, pid)
    {:ok, pid}
  end

  def init(tasks) do
    state = %{tasks: tasks}
    {:ok, state}
  end

  def run(pipeline_id, data) do
    case Registry.lookup(PipelineRegistry, pipeline_id) do
      [{_pid, pid}] -> GenServer.cast(pid, {:run, data})
      [] -> :noop
    end
  end

  def accept_confirmation(%{pipeline: pipeline_id} = task, [bid]) do
    case Registry.lookup(PipelineRegistry, pipeline_id) do
      [{_pid, pid}] -> GenServer.cast(pid, {:accept_confirmation, task, [bid]})
      [] -> :noop
    end
  end

  def handle_cast({:accept_confirmation, task, bids}, state) do
    update = fn
      ^task -> {task, bids}
      t -> t
    end
    new_state =
      state
      |> Map.update!(:tasks, &Enum.map(&1, update))
      |> check_readiness()
    {:noreply, new_state}
  end

  def handle_cast({:run, data}, state) do
    %{pid: pid} = state
    GenStage.cast(pid, {:run, data})
    {:noreply, state}
  end

  defp check_readiness(state) do
    case all_confirmed?(state.tasks) do
      true -> Map.put_new(state, :pid, start_pipeline(state.tasks))
      false -> state
    end
  end

  defp all_confirmed?([]), do: true
  defp all_confirmed?([%Task{} | _]), do: false
  defp all_confirmed?([{%Task{}, _} | rest]), do: all_confirmed?(rest)

  def start_pipeline(tasks) do
    tasks
    |> Enum.map(fn {task, bids} -> Stage.start_node(task, bids) end)
    |> List.insert_at(0, Producer.start_link())
    |> List.insert_at(-1, Consumer.start_link())
    |> Enum.map(fn {:ok, pid} -> pid end)
    |> Enum.reverse()
    |> subscribe_stages()
  end

  defp subscribe_stages([s | []]), do: s

  defp subscribe_stages([s, n | rest]) do
    GenStage.sync_subscribe(s, to: n)
    subscribe_stages([n | rest])
  end
end
