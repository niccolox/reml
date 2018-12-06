defmodule Reml.App do
  @moduledoc """
  Documentation for Reml ABCI App.
  """

  alias ABCI.Types
  alias PalliumCore.Core.Transaction, as: Tx
  alias Reml.ABCI.Response
  alias Reml.App.State
  alias Reml.App.TransactionController
  alias Reml.App.TxValidator
  alias Reml.App.Task.TaskController

  require Logger

  @code_type_ok 0
  # @code_type_encoding_error 1
  # @code_type_bad_nonce 2
  # @code_type_unauthorized 3

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage

  def handle(message, request) do
    process(message, request)
    # |> IO.inspect(label: "App.handle(#{inspect message})")
  end

  def process(:info, _req) do
    state = State.get()

    Types.ResponseInfo.new(
      data: "#{inspect(state)}",
      last_block_height: state.last_block_height,
      last_block_app_hash: state.last_block_app_hash
    )
  end

  def process(:init_chain, _req) do
    Types.ResponseInitChain.new()
  end

  def process(:begin_block, _req) do
    Types.ResponseBeginBlock.new(code: @code_type_ok)
  end

  def process(:end_block, _req) do
    TaskController.check_unassigned_tasks()
    Types.ResponseEndBlock.new(code: @code_type_ok)
  end

  def process(:commit, _req) do
    IO.puts("COMMIT\n\n\n")
    # response hash state
    Types.ResponseCommit.new(data: "tree state")
  end

  def process(:flush, _req) do
    Types.ResponseFlush.new()
  end

  def process(:echo, req) do
    msg = req.message
    Types.ResponseEcho.new(message: msg)
  end

  def process(:set_option, _req) do
    Types.ResponseSetOption.new()
  end

  def process(:deliver_tx, req) do
    req.tx
    |> Tx.decode()
    |> IO.inspect(label: :processing_tx)
    |> TransactionController.execute()
    |> Response.deliver_tx()
  end

  def process(:check_tx, %{tx: tx}) do
    resp =
      tx
      |> Tx.decode()
      |> TxValidator.validate()
      |> Response.check_tx()
        
    case resp.code do
      0 -> :ok
      _ -> Logger.warn("TX declined: #{resp.info}")
    end

    resp
  end
end
