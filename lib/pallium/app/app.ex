defmodule Pallium.App do
  @moduledoc """
  Documentation for Pallium ABCI App.
  """

  alias ABCI.Types
  alias Pallium.ABCI.Response
  alias Pallium.App.State
  alias PalliumCore.Core.Transaction, as: Tx
  alias Pallium.Core.TransactionController
  alias Pallium.Core.TxValidator

  @code_type_ok 0
  # @code_type_encoding_error 1
  # @code_type_bad_nonce 2
  # @code_type_unauthorized 3

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage

  def init do
    State.start_link()
    ABCI.start_link(__MODULE__)
  end

  def info(_req) do
    state = State.get()

    Types.ResponseInfo.new(
      data: "#{inspect(state)}",
      last_block_height: state.last_block_height,
      last_block_app_hash: state.last_block_app_hash
    )
  end

  def init_chain(_req) do
    Types.ResponseInitChain.new()
  end

  def begin_block(_req) do
    Types.ResponseBeginBlock.new(code: @code_type_ok)
  end

  def end_block(_req) do
    Types.ResponseEndBlock.new(code: @code_type_ok)
  end

  def commit(_req) do
    # response hash state
    Types.ResponseCommit.new(data: <<>>)
  end

  def flush(_req) do
    Types.ResponseFlush.new()
  end

  def echo(req) do
    msg = req.message
    Types.ResponseEcho.new(message: msg)
  end

  def set_option(_req) do
    Types.ResponseSetOption.new()
  end

  def deliver_tx(req) do
    req.tx
    |> Tx.decode()
    |> TransactionController.execute()
    |> Response.deliver_tx()
  end

  def check_tx(%{tx: tx}) do
    tx
    |> Tx.decode()
    |> TxValidator.validate()
    |> Response.check_tx()
  end
end
