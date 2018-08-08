defmodule Pallium.Core.Message do
  @moduledoc false

  alias Pallium.Core.Message

  defstruct action: <<>>,
            props: <<>>

  @type t :: %__MODULE__{
          action: binary(),
          props: binary()
        }

  @spec serialize(t) :: ExRLP.t()
  def serialize(message) do
    [
      message.action,
      message.props
    ]
  end

  @spec deserialize(ExRLP.t()) :: t
  def deserialize(rlp) do
    [
      action,
      props
    ] = rlp

    %__MODULE__{
      action: action,
      props: props
    }
  end

  def new(action, props) do
    %__MODULE__{%Message{} | action: action, props: props} |> serialize() |> ExRLP.encode(encoding: :hex)
  end

  def decode(rlp) do
    rlp |> ExRLP.decode(encoding: :hex) |> deserialize()
  end
end
