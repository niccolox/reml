defmodule Reml.App.Task.TaskController do
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Transaction, as: Tx
  alias Reml.App.AgentController
  alias Reml.App.Pipeline
  alias Reml.App.State
  alias Reml.App.Task
  alias Reml.App.Task.Allocator
  alias Reml.App.Task.BidStorage
  alias Reml.App.Task.ConfirmationStorage
  alias Reml.App.Task.TaskStorage
  alias Reml.Tendermint.TMNode
  alias Reml.Tendermint.RPC

  def add_task(from, to, task, pipeline \\ "") do
    task = %Task{
      from: from,
      to: to,
      task: task,
      pipeline: pipeline,
      created_at: State.last_block_height()
    }
    TaskStorage.add_task(task)
    check_task(task)
    task
  end

  def check_unassigned_tasks do
    :unassigned
    |> TaskStorage.find_by_status()
    |> Enum.each(&check_task/1)
  end

  defp check_task(task) do
    task
    |> allocate_bids()
    |> Enum.filter(&current_node?/1)
    |> Enum.each(&assign(&1, task))
  end

  defp allocate_bids(task) do
    bids = BidStorage.get_all()
    Allocator.allocate(Task.ask(task), bids, Task.age(task))
  end

  defp current_node?(%Bid{node_id: node_id}) do
    node_id == TMNode.address()
  end

  #TODO: mark bid as assigned to prevent double-assigning
  defp assign(bid, task) do
    send_confirmation(bid, task)
    TaskStorage.assign(task)
  end

  defp send_confirmation(bid, task) do
    %Tx{
      type: :confirm,
      from: TMNode.address(),
      data: [Bid.encode(bid), Task.encode(task)],
    }
    |> RPC.send_tx()
  end

  def new_confirmation(bid, task) do
    BidStorage.delete_bid(bid)
    ConfirmationStorage.add_confirmation(task, bid)
    case ConfirmationStorage.get_workers(task) do
      nil ->
        :noop

      bids when is_list(bids) ->
        process_confirmation(task, bids)
    end
    :ok
  end

  defp process_confirmation(%Task{pipeline: ""} = task, [master_bid | worker_bids]) do
    run_node(task, master_bid, :master)
    Enum.map(worker_bids, &run_node(task, &1, :worker))
  end

  defp process_confirmation(task, bids), do: Pipeline.accept_confirmation(task, bids)

  defp run_node(task, bid, _mode) do
    cond do
      bid.node_id == TMNode.address ->
        AgentController.send(task.to, task.task, task.params)

      true ->
        :noop
    end
  end
end

