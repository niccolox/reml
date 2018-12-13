defmodule Reml.Tendermint.RPC do
  require Logger

  alias PalliumCore.Core.Transaction, as: Tx
  alias Ethereumex.HttpClient

  def send_tx(%Tx{} = tx) do
    encoded_tx =
      tx
      |> set_nonce()
      |> Tx.encode(:base64)
    request("broadcast_tx_commit", %{tx: encoded_tx})
  end

  defp set_nonce(tx) do
    # FIXME: use proper nonce
    nonce = :rand.uniform(1000000)
    %Tx{tx | nonce: nonce}
  end

  def status do
    request("status")
  end

  def tx(hash) do
    params = %{hash: hash |> Base.decode16!() |> Base.encode64()}
    request("tx", params)
  end

  defp request(method, params \\ []) do
    HttpClient.request(method, params, [])
    |> case do
      {:error, :econnrefused} ->
        Logger.warn("Could not connect to Tendermint RPC server")

      result ->
        result
    end
  end
end
