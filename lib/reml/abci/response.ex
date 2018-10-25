defmodule Reml.ABCI.Response do
  @moduledoc """
  Adapter for building ABCI responses
  """

  alias ABCI.Types.ResponseCheckTx
  alias ABCI.Types.ResponseDeliverTx

  @check_tx_codes %{
    ok: 0,
    agent_missing: 1,
  }

  @deliver_tx_codes %{
    ok: 0,
    encoding_error: 1,
    bad_nonce: 2,
    unauthorized: 3,
  }

  def check_tx(:ok), do: ResponseCheckTx.new(code: @check_tx_codes.ok)

  def check_tx({:agent_missing, address}) do
    ResponseCheckTx.new(
      code: @check_tx_codes.agent_missing,
      info: "Agent #{address} does not exist"
    )
  end

  def deliver_tx(:ok), do: ResponseDeliverTx.new(code: @deliver_tx_codes.ok)

  def deliver_tx({:ok, result}) when is_atom(result), do: deliver_tx({:ok, to_string(result)})

  def deliver_tx({:ok, result}) do
    ResponseDeliverTx.new(
      code: @deliver_tx_codes.ok,
      data: result
    )
  end

  def deliver_tx({:error, _reason}) do
    ResponseDeliverTx.new(
      code: @deliver_tx_codes.encoding_error
    )
  end
end
