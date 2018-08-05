defmodule Pallium.Core.Transaction do
  @moduledoc false

  alias Pallium.Core.{Agent, Address, Transaction}

  defstruct nonce: 0,
            type: <<>>,
            to: <<>>,
            from: <<>>,
            value: 0,
            data: <<>>,
            sign: <<>>

  @type tx :: %__MODULE__{
          nonce: integer(),
          type: atom(),
          to: Address.address() | <<_::0>>,
          from: Address.address() | <<_::0>>,
          value: integer(),
          data: binary(),
          sign: binary()
        }

  @spec serialize(tx) :: ExRLP.t()
  def serialize(tx) do
    [
      tx.nonce,
      tx.type,
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
      type,
      to,
      from,
      value,
      data,
      sign
    ] = rlp

    %__MODULE__{
      nonce: :binary.decode_unsigned(nonce),
      type: String.to_atom(type),
      to: to,
      from: from,
      value: :binary.decode_unsigned(value),
      data: data,
      sign: sign
    }
  end

  def create(raw) do
    {nonce, type, to, from, value, data} = raw

    %__MODULE__{
      %Transaction{}
      | nonce: nonce,
        type: Atom.to_string(type),
        to: to,
        from: from,
        value: value,
        data: data
    }
  end

  def send(tx) do
    host = Application.get_env(:pallium, :host)
    broadcast = Application.get_env(:pallium, :broadcast)
    encoded_tx = tx |> serialize() |> ExRLP.encode(encoding: :hex)
    JSONRPC2.Clients.HTTP.call(host <> broadcast <> "0x" <> encoded_tx, "", [])
  end

  def execute(hex_rlp) do
    tx = hex_rlp |> ExRLP.decode(encoding: :hex) |> deserialize()

    case tx.type do
      :create -> Agent.create(tx.data, tx.to)
      :transfer -> Agent.transfer(tx.to, tx.from, tx.value)
      :send -> Agent.send(tx.to, tx.data)
      _ -> {:reject, "Execution failure"}
    end
  end
end
