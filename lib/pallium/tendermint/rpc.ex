defmodule Pallium.Tendermint.RPC do
  require Logger

  alias PalliumCore.Core.Transaction, as: Tx
  alias JSONRPC2.Clients.HTTP

  def broadcast_tx_commit(tx) do
    params = %{tx: Tx.encode(tx, :base64)}
    request("broadcast_tx_commit", params)
  end

  def status do
    request("status")
  end

  def tx(hash) do
    params = %{hash: hash |> Base.decode16!() |> Base.encode64()}
    request("tx", params)
  end

  defp request(method, params \\ []) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host, method, params)
    |> case do
      {:error, :econnrefused} ->
        Logger.warn("Could not connect to Tendermint RPC server")

      result ->
        result
    end
  end
end
