defmodule Reml.Api.Resolvers.Message do
  @moduledoc false

  alias PalliumCore.Core.Message

  @doc """
  Get new message

  Return: Hex RLP encoding message struct

  ## Arguments
    - args.action: Action string
    - args.props: Props string
  """
  def new(_parent, args, _resolution) do
    rlp =
      %Message{action: args.action, props: args.props}
      |> Message.encode()
    {:ok, %{rlp: rlp}}
  end
end
