defmodule StoreTest do
  use ExUnit.Case

  alias MerklePatriciaTree.{Test, Trie}
  alias Pallium.Core.Store

  doctest Store

  test "write and read Store" do
    Test.random_ets_db() |> Trie.new() |> Store.start_link()
    assert Store.update(<<0x01::4, 0x02::4>>, "wee") == :ok
    assert Store.update(<<0x01::4, 0x02::4, 0x03::4>>, "cool") == :ok
    assert Store.get(<<0x01::4, 0x02::4>>) == "wee"
    assert Store.get(<<0x01::4, 0x02::4, 0x03::4>>) == "cool"
  end
end
