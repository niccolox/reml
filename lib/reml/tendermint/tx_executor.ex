defmodule Reml.Tendermint.TxExecutor do
  @moduledoc false

  alias Reml.App.AgentController
  alias Reml.App.Pipeline
  alias Reml.App.Task
  alias Reml.App.Task.BidStorage
  alias Reml.App.Task.TaskController
  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Message
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  def execute_tx(%Tx{type: type} = tx) do
    execute(type, tx)
    |> IO.inspect(label: "Executing tx #{type}")
  end

  defp execute(:create, tx) do
    [agent_rlp, encoded_params] = tx.data
    params = Crypto.decode_map(encoded_params)
    agent = Agent.decode(agent_rlp)
    AgentController.create(agent, tx.from, params)
  end

  defp execute(:transfer, tx) do
    AgentController.transfer(tx.to, tx.from, tx.value)
  end

  defp execute(:send, tx) do
    message = Message.decode(tx.data)
    AgentController.send(tx.to, message.action, message.props)
  end

  defp execute(:bid, %Tx{data: data}) do
    data
    |> Bid.decode()
    |> BidStorage.add_bid()
  end

  defp execute(:confirm, tx) do
    [bid_rlp, task_rlp] = tx.data
    bid = Bid.decode(bid_rlp)
    task = Task.decode(task_rlp)
    TaskController.new_confirmation(bid, task)
  end

  defp execute(:start_pipeline, tx) do
    # TODO: uniq tx id, could be swiched to tx.sign when its implemented
    tx_id =
      tx
      |> Tx.encode()
      |> Crypto.hash()
      |> Base.encode64()

    Pipeline.create(tx.from, tx.data, tx_id)
    {:ok, tx_id}
  end

  defp execute(:run_pipeline, %Tx{data: [pipeline_id, input]}) do
    Pipeline.run(pipeline_id, input)
    {:ok, "Done"}
  end

  defp execute(_, %Tx{} = tx) do
    {:reject, "Execution failure: unknown tx type #{inspect tx.type}"}
  end
end
