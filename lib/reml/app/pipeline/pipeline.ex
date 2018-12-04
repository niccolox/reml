defmodule Reml.App.Pipeline do
  use GenServer

  alias Reml.App.Pipeline.Consumer
  alias Reml.App.Pipeline.Producer
  alias Reml.App.Task
  alias Reml.App.Task.TaskController
  alias Reml.Tendermint.TMNode

  def start_link(required_agents) do
    {:ok, pid} = GenServer.start_link(__MODULE__, required_agents)
    address = TMNode.address()
    {pid, address} |> encode()
  end

  def run(id, data) do
    {pid, address} = decode(id)
    case TMNode.address() do
      ^address -> GenServer.call(pid, {:run, data})
      _ -> :wrong_node
    end
  end

  def accept_confirmation(task, [bid]) do
    address = TMNode.address()
    task
    |> Map.fetch!(:pipeline)
    |> decode()
    |> case do
      {pid, ^address} -> GenServer.cast(pid, {:accept_confirmation, task, [bid]})
      {_, _} -> :wrong_address
    end
  end

  def encode({pid, address}) do
    [Helpers.pid_to_binary(pid), Base.encode64(address)]
  end

  def decode([pid_str, address_str]) do
    {Helpers.pid_from_string(pid_str), Base.decode64!(address_str)}
  end

  def init(required_agents) do
    pipeline = {self(), TMNode.address()} |> encode()
    tasks = Enum.map(required_agents, fn agent ->
      TaskController.add_task("", agent, "", pipeline)
    end)
    state = %{tasks: tasks}
    {:ok, state}
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
    |> IO.inspect(label: "Accepting confirmation")
    # update confirmed agents
    # if all confirmed -> start pipeline
  end

  def handle_cast({:run, data}, _from, state) do
    %{pid: pid} = state
    GenStage.cast(pid, {:run, data})
    {:noreply, state}
  end

  defp check_readiness(state) do
    case all_confirmed?(state.tasks) do
      true -> %{state | pid: start_pipeline(state.tasks)}
      false -> state
    end
  end

  defp all_confirmed?([]), do: true
  defp all_confirmed?([%Task{} | _]), do: false
  defp all_confirmed?([{%Task{}, _} | rest]), do: all_confirmed?(rest)

  def start_pipeline(tasks) do
    IO.inspect(tasks, label: "Starting pipeline on")
    tasks
    |> Enum.map(fn {task, bids} -> Stage.start_node(task, bids) end)
    |> List.insert_at(Producer.start_link(), 0)
    |> List.insert_at(Consumer.start_link(), -1)
    |> Enum.reverse()
    |> subscribe_stages()
  end

  defp subscribe_stages([s | []]), do: s

  defp subscribe_stages([s, n | rest]) do
    GenStage.sync_subscribe(s, to: n)
    subscribe_stages([n | rest])
  end
end
