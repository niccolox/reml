defmodule Pallium.Api.Resolvers.Transaction do
  alias Pallium.Core.Transaction, as: Tx

  def send(_parent, args, _resolution) do
    type = String.to_atom(args.type)
    data = args.data |> Helpers.from_hex()
    tx = {0, type, args.to, args.from, args.value, data} |> Tx.create() |> Tx.send()
    # encoded_tx = tx |> Tx.serialize() |> ExRLP.encode(encoding: :hex) |> Tx.send()
    # #res = Tx.execute(encoded_tx)
    {:ok, %{rlp: "123"}}
  end
end
