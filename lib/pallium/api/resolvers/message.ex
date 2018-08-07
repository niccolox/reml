defmodule Pallium.Api.Resolvers.Message do
  @moduledoc false

  alias Pallium.Core.Message

  @doc """
  Get new message

  Return: Hex RLP encoding message struct

  ## Arguments
    - args.action: Action string
    - args.props: Props string
  """
  def new(_parent, args, _resolution) do
    {:ok, %{rlp: Message.new(args.action, args.props)}}
  end
end
