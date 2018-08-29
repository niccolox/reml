defmodule TxHelpers do
  alias Pallium.Core.Transaction, as: Tx

  def run(nonce, type, to, from, value, data) do
    run({nonce, type, to, from, value, data})
  end

  def run(raw) do
    raw
    |> Tx.new()
    |> Helpers.from_hex()
    |> Tx.execute()
  end
end
