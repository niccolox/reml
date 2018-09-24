defmodule Pallium.App.TransactionController do
  @moduledoc false

  alias Pallium.App.AgentController
  alias Pallium.Tendermint.RPC
  alias PalliumCore.Core.Agent
  alias PalliumCore.Core.Bid
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  def send(%Tx{} = tx) do
    RPC.broadcast_tx_commit(tx)
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
        Bid.decode(tx.data) |> AgentController.bid()

      _ ->
        {:reject, "Execution failure: unknown tx type #{inspect tx.type}"}
    end
  end
end
