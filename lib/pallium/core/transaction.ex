defmodule Pallium.Core.Transaction do
  @moduledoc false

  alias JSONRPC2.Clients.HTTP
  alias Pallium.Core.{Address, Agent}

  @broadcast "broadcast_tx_commit?tx=0x"
  @check_tx "tx?hash=0x"

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

  def encode(%{} = tx) do
    tx
    |> serialize()
    |> ExRLP.encode()
  end

  def decode(rlp) do
    rlp
    |> ExRLP.decode()
    |> deserialize()
  end

  def new({nonce, type, to, from, value, data}) do
    %__MODULE__{
      nonce: nonce,
      type: Atom.to_string(type),
      to: to,
      from: from,
      value: value,
      data: data
    }
    |> serialize()
    |> ExRLP.encode(encoding: :hex)
  end

  def send(%__MODULE__{} = tx) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host <> @broadcast <> tx, "", [])
  end

  def send(tx), do: tx |> new() |> send()

  def check(hash) do
    host = Application.get_env(:pallium, :host)
    HTTP.call(host <> @check_tx <> hash, "", [])
  end

  def execute(rlp) do
    tx = rlp |> ExRLP.decode() |> deserialize()
    case tx.type do
      :create ->
        [agent_rlp, encoded_params] = tx.data
        params = Helpers.decode_map(encoded_params)
        Agent.create(tx.to, agent_rlp, params)

      :transfer -> Agent.transfer(tx.to, tx.from, tx.value)
      :send -> Agent.send(tx.to, tx.data)
      :bid -> Agent.bid(tx.from, tx.data)
      _ -> {:reject, "Execution failure"}
    end
  end
end
