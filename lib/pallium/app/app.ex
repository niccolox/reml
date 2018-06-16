defmodule Pallium.App do
  @moduledoc """
  Documentation for Pallium ABCI App.
  """

  @code_type_ok 0
  @code_type_encoding_error 1
  @code_type_bad_nonce 2
  @code_type_unauthorized 3

  alias ABCI.Types
  alias Pallium.App.State
  alias Pallium.Myelin.Transaction

  def start_link() do
    spawn(fn -> init() end)
  end

  def init() do
    State.init()
    ABCI.init(__MODULE__)
  end

  def info(req) do
    # IO.inspect(req)
    state = State.get()

    Types.ResponseInfo.new(
      data: "#{inspect(state)}",
      last_block_height: state.last_block_height,
      last_block_app_hash: state.last_block_app_hash
    )
  end

  def init_chain(req) do
    # IO.inspect(req)
    Types.ResponseInitChain.new()
  end

  def begin_block(req) do
    # IO.inspect(req)
    Types.ResponseBeginBlock.new(code: @code_type_ok)
  end

  def end_block(req) do
    # IO.inspect(req)
    Types.ResponseEndBlock.new(code: @code_type_ok)
  end

  def commit(req) do
    # response hash state
    # IO.inspect(req)
    Types.ResponseCommit.new(data: <<>>)
  end

  def flush(req) do
    _ = req
    Types.ResponseFlush.new()
  end

  def echo(req) do
    msg = req.message
    Types.ResponseEcho.new(message: msg)
  end

  def set_option(req) do
    Types.ResponseSetOption.new()
  end

  def deliver_tx(req) do
    case Transaction.execute(req.tx) do
      :ok -> Types.ResponseDeliverTx.new(code: @code_type_ok)
      {:ok, result} -> Types.ResponseDeliverTx.new(code: @code_type_ok, data: result)
      {:error, reason} -> Types.ResponseDeliverTx.new(code: @code_type_encoding_error)
    end
  end

  def check_tx(req) do
    Types.ResponseCheckTx.new(code: @code_type_ok)
  end
end
