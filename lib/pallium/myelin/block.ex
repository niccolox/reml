defmodule Pallium.Myelin.Block do
  @moduledoc """
  Documentation for Block of Myelin Blockchain.
  """

  alias Pallium.Myelin
  alias Myelin.Transaction
  alias Myelin.Block.Header

  defstruct block_hash: nil,
            header: %Header{},
            transactions: []

  @type t :: %__MODULE__{
          block_hash: Myelin.hash() | nil,
          header: Header.t(),
          transactions: [Transaction.tx()]
        }

  @spec hash(t) :: Myelin.hash()
  def hash(block) do
    block.header |> Header.hash()
  end
end
