defmodule Pallium.Myelin.Transaction do
  alias Pallium.App
  alias Pallium.Myelin.Store
  alias Pallium.Myelin.Agent

  defstruct nonce: 0,
            to: <<>>,
            from: <<>>,
            value: 0,
            data: <<>>,
            sign: <<>>

  @type tx :: %__MODULE__{
          nonce: integer(),
          to: Pallium.Myelin.Address.address() | <<_::0>>,
          from: Pallium.Myelin.Address.address() | <<_::0>>,
          value: integer(),
          data: binary(),
          sign: binary()
        }

  @spec serialize(tx) :: ExRLP.t()
  def serialize(tx) do
    [
      tx.nonce,
      tx.to,
      tx.from,
      tx.value,
      tx.data,
      tx.sign
    ]
  end

  @spec deserialize(ExRLP.t()) :: tx
  def deserialize(rlp) do
    [
      nonce,
      to,
      from,
      value,
      data,
      sign
    ] = rlp

    %__MODULE__{
      nonce: :binary.decode_unsigned(nonce),
      to: to,
      from: from,
      value: :binary.decode_unsigned(value),
      data: data,
      sign: sign
    }
  end

  def create(raw) do
    {nonce, to, from, value, data} = raw

    tx = %__MODULE__{
      %Pallium.Myelin.Transaction{}
      | nonce: nonce,
        to: to,
        from: from,
        value: value,
        data: data
    }
  end

  def send(tx) do
    IO.inspect(tx)
    host = Application.get_env(:pallium, :host)
    broadcast = Application.get_env(:pallium, :broadcast)
    encoded_tx = tx |> serialize() |> ExRLP.encode() |> Helpers.to_hex()
    IO.puts("Request: #{inspect(encoded_tx)}")
    result = JSONRPC2.Clients.HTTP.call(host <> broadcast <> "0x" <> encoded_tx, "", [])
    IO.inspect(result)
  end

  def execute(rlp) do
    tx = rlp |> ExRLP.decode() |> deserialize()
    IO.inspect(tx)
    agent = Store.get(tx.to)

    if agent do
      Agent.transfer(tx.to, tx.from, tx.value)
    else
      Agent.put(tx.data, tx.to)
    end

    {:ok, <<0>>}
  end
end
