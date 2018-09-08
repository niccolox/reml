defmodule Pallium.Core.Transaction do
  @moduledoc false

  alias JSONRPC2.Clients.HTTP
  alias Pallium.Core.Agent
  alias PalliumCore.Core.Transaction, as: Tx
  alias PalliumCore.Crypto

  @broadcast "broadcast_tx_commit?tx=0x"
  @check_tx "tx?hash=0x"


  def send(tx) when is_binary(tx) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host <> @broadcast <> tx, "", [])
  end

  def send(%Tx{} = tx), do: tx |> Tx.encode() |> send()

  def check(hash) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host <> @check_tx <> hash, "", [])
  end

  def execute(rlp) when is_binary(rlp), do: rlp |> Tx.decode() |> execute()

  def execute(%Tx{} = tx) do
    case tx.type do
      :create ->
        [agent_rlp, encoded_params] = tx.data
        params = Crypto.decode_map(encoded_params)
        Agent.create(agent_rlp, tx.to, params)

      :transfer -> Agent.transfer(tx.to, tx.from, tx.value)
      :send -> Agent.send(tx.to, tx.data)
      :bid -> Agent.bid(tx.from, tx.data)
      _ -> {:reject, "Execution failure"}
    end
  end
end
