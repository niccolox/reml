defmodule Pallium.Myelin.Message do
  defstruct action: <<>>,
            data: <<>>

  @type t :: %__MODULE__{
          action: binary(),
          data: binary(),
        }

  @spec serialize(t) :: ExRLP.t()
  def serialize(message) do
    [
      message.action,
      message.data
    ]
  end

  @spec deserialize(ExRLP.t()) :: t
  def deserialize(rlp) do
    [
      action,
      data
    ] = rlp

    %__MODULE__{
      action: action,
      data: data
    }
  end

  def create(action, data) do
    %__MODULE__{%Pallium.Myelin.Message{} | action: action, data: data} |> serialize() |> ExRLP.encode()
  end

  def decode(rlp) do
    rlp |> ExRLP.decode() |> deserialize()
  end

end
