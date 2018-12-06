defmodule Reml.App.TransactionController do
  @moduledoc false

  alias Reml.App.AgentController
  alias Reml.App.Pipeline
  alias Reml.App.Task
  alias Reml.App.Task.TaskController
  alias Reml.Tendermint.RPC
  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Message
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  def send(%Tx{} = tx) do
    tx
    |> set_nonce()
    |> RPC.broadcast_tx_commit()
  end

  defp set_nonce(tx) do
    # FIXME: use proper nonce
    nonce = :rand.uniform(1000000)
    %Tx{tx | nonce: nonce}
  end

  def execute(%Tx{type: :create} = tx) do
    [agent_rlp, encoded_params] = tx.data
    params = Crypto.decode_map(encoded_params)
    agent = Agent.decode(agent_rlp)
    AgentController.create(agent, tx.from, params)
  end

  def execute(%Tx{type: :transfer} = tx) do
    AgentController.transfer(tx.to, tx.from, tx.value)
  end

  def execute(%Tx{type: :send} = tx) do
    message = Message.decode(tx.data)
    AgentController.send(tx.to, message.action, message.props)
  end

  def execute(%Tx{type: :bid, data: data}) do
    data
    |> Bid.decode()
    |> AgentController.bid()
  end

  def execute(%Tx{type: :confirm} = tx) do
    [bid_rlp, task_rlp] = tx.data
    bid = Bid.decode(bid_rlp)
    task = Task.decode(task_rlp)
    TaskController.new_confirmation(bid, task)
  end

  def execute(%Tx{type: :start_pipeline, from: from, data: agents} = tx) do
    # TODO: uniq tx id, could be swiched to tx.sign when its implemented
    tx_id =
      tx
      |> Tx.encode()
      |> Crypto.hash()
      |> Base.encode64()

    Pipeline.create(from, agents, tx_id)
    {:ok, tx_id}
  end

  def execute(%Tx{type: :run_pipeline, data: [pipeline_id, input]}) do
    Pipeline.run(pipeline_id, input)
    |> IO.inspect(label: "Run pipeline")
    {:ok, "Done"}
  end

  def execute(%Tx{} = tx) do
    {:reject, "Execution failure: unknown tx type #{inspect tx.type}"}
  end
end
