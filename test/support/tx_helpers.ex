defmodule TxHelpers do
  alias Pallium.Core.Transaction
  alias PalliumCore.Core.Transaction, as: Tx

  def run(nonce, type, to, from, value, data) do
    run({nonce, type, to, from, value, data})
  end

  def run({nonce, type, to, from, value, data}) do
    %Tx{
      nonce: nonce,
      type: type,
      to: to,
      from: from,
      value: value,
      data: data
    }
    |> Transaction.execute()
  end
end
