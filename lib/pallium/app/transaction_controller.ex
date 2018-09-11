defmodule Pallium.App.TransactionController do
  @moduledoc false

  alias JSONRPC2.Clients.HTTP
  alias Pallium.App.AgentController
  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  def send(%Tx{} = tx) do
    params = %{tx: Tx.encode(tx, :base64)}
    rpc_request("broadcast_tx_commit", params)
  end

  def check(hash) do
    params = %{hash: hash |> Base.decode16!() |> Base.encode64()}
    rpc_request("tx", params)
  end

  @doc """
  Sends JSONRPC2 request to tendermint
  Params - map with base64 encoded values
  """
  def rpc_request(method, params \\ []) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host, method, params)
  end

  def execute(%Tx{} = tx) do
    case tx.type do
      :create ->
        [agent_rlp, encoded_params] = tx.data
        params = Crypto.decode_map(encoded_params)
        agent = Agent.decode(agent_rlp)
        AgentController.create(agent, tx.from, params)

      :transfer ->
        AgentController.transfer(tx.to, tx.from, tx.value)

      :send ->
        AgentController.send(tx.to, tx.data)

      :bid ->
        bid = Bid.decode(tx.data)
        AgentController.bid(tx.from, bid)

      _ ->
        {:reject, "Execution failure: unknown tx type #{inspect tx.type}"}
    end
  end
end
