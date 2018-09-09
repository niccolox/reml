defmodule Pallium.App.TransactionController do
  @moduledoc false

  alias JSONRPC2.Clients.HTTP
  alias Pallium.App.AgentController
  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  @broadcast "broadcast_tx_commit?tx=0x"
  @check_tx "tx?hash=0x"

  def send(%Tx{} = tx) do
    tx_hex = Tx.encode(tx, :hex)
    http_request(@broadcast <> tx_hex)
  end

  def check(hash) do
    http_request(@check_tx <> hash)
  end

  # TODO: use proper method and params in request
  defp http_request(request) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host <> request, "", [])
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
