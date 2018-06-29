defmodule Pallium.Myelin.Transaction do
  import Sage

  alias Pallium.App
  alias Pallium.Myelin.Store
  alias Pallium.Myelin.Agent

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

    tx = %__MODULE__{
      %Pallium.Myelin.Transaction{}
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
    encoded_tx = tx |> serialize() |> ExRLP.encode() |> Helpers.to_hex()
    JSONRPC2.Clients.HTTP.call(host <> broadcast <> "0x" <> encoded_tx, "", [])
  end

  def execute(rlp) do
    tx = rlp |> ExRLP.decode() |> deserialize()
    case tx.type do
      :create -> Agent.create(tx.data, tx.to)
      :transfer -> Agent.transfer(tx.to, tx.from, tx.value)
      :send -> Agent.send(tx.to, tx.data)
      :channel -> Agent.channel(tx.to, tx.data)
      _ -> {:reject, "Execution failure"}
    end
  end
end
