defmodule Reml.Tendermint.Handler do

  import Reml.Tendermint.TxExecutor
  import Reml.Tendermint.TxValidator

  alias PalliumCore.Core.Transaction, as: Tx
  alias Reml.App.State
  alias Reml.App.Task.TaskController
  alias Reml.Tendermint.Response

  require Logger

  def handle(message, request) do
    params = process(message, request) |> IO.inspect(label: "Processing #{message}")
    Response.build(message, params)
  end

  def process(message, _request) when message in ~w(init_chain begin_block flush set_option)a, do: :ok

  def process(:info, _req) do
    state = State.get()
    [
      data: inspect(state),
      last_block_height: state.last_block_height,
      last_block_app_hash: state.last_block_app_hash
    ]
  end

  def process(:end_block, _req) do
    :ok = TaskController.check_unassigned_tasks()
  end

  def process(:commit, _req) do
    # response hash state
    [data: "tree state"]
  end

  def process(:echo, req) do
    [message: req.message]
  end

  def process(:deliver_tx, req) do
    req.tx
    |> Tx.decode()
    |> execute_tx()
  end

  def process(:check_tx, %{tx: tx}) do
    tx
    |> Tx.decode()
    |> validate_tx()
    |> case do
      :ok ->
        :ok

      {:error, {type, message}} ->
        Logger.warn("TX declined: " <> message)
        {:error, {type, message}}
    end
  end
end
