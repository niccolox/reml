defmodule Pallium.Myelin.Block.Header do
  @moduledoc """
  Documentation for Block Header of Myelin Blockchain.
  """
  alias Pallium.Myelin, as: Myelin

  @empty_trie MerklePatriciaTree.Trie.empty_trie_root_hash()

  defstruct parent_hash: nil,
            number: nil,
            store_root: @empty_trie,
            tx_root: @empty_trie,
            timestamp: nil,
            nonce: nil

  @type t :: %__MODULE__{
          parent_hash: Myelin.hash(),
          number: integer(),
          store_root: Myelin.trie_root(),
          tx_root: Myelin.trie_root(),
          timestamp: Myelin.timestamp(),
          nonce: integer()
        }

  @spec serialize(t) :: ExRLP.t()
  def serialize(h) do
    [
      h.parent_hash,
      h.number,
      h.store_root,
      h.tx_root,
      h.timestamp,
      h.nonce
    ]
  end

  @spec deserialize(ExRLP.t()) :: t
  def deserialize(rlp) do
    [
      parent_hash,
      number,
      store_root,
      tx_root,
      timestamp,
      nonce
    ] = rlp

    %__MODULE__{
      parent_hash: parent_hash,
      number: number,
      store_root: store_root,
      tx_root: tx_root,
      timestamp: timestamp,
      nonce: nonce
    }
  end

  @spec hash(t) :: Myelin.hash()
  def hash(header) do
    header |> serialize() |> ExRLP.encode() |> Helpers.keccak()
  end
end
