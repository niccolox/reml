defmodule Pallium.Myelin do
  @moduledoc """
  Documentation for Pallium Blockchain.
  """
  @type hash :: <<_::256>>
  @type trie_root :: MerklePatriciaTree.Trie.root_hash()
  @type timestamp :: integer()

  defstruct genesis: %{}

  @type myelin :: %__MODULE__{
          genesis: %{
            nonce: integer()
          }
        }

  def init() do
    home = System.user_home()
    File.rm_rf("#{home}/.pallium")

    {_, db_ref} =
      case File.mkdir("#{home}/.pallium") do
        :ok -> MerklePatriciaTree.DB.LevelDB.init("#{home}/.pallium/store")
      end

    Exleveldb.close(db_ref)
  end
end
