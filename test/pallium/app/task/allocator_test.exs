defmodule Pallium.App.AllocatorTest do
  @moduledoc """
  ## @network

  @network defines network topology - bids, grouped by nodes and clusters.

  Each bid is defined by a letter "a", "b", "c" - where "a" stands for lowest configuration,
  "b" - more powerful device, and so on.

  Each node is defined by a "word", e.g. "2a2b" - node with 2 devices of type "a" + 2 devices
  of type "b".

  Cluster defined by a line, starting with cluster id.

  So line "5 4c" stands for "cluster with id 5, consisting of one node 4c".


  ## @matches

  @matches defines test cases.

  Each line contains given Ask and batches, expected to be returned by Allocator.allocate/2.

  Ask "4b/c" means Ask for 4 devices of type "b" in the same cluster.  Modifier "/n" stands
  for "same node".

  Batches are separated by " - ". "3x4.1.b" stands for "3 bids of type `b` from cluster 4,
  node 1"
  """

  use ExUnit.Case

  alias Pallium.App.Task.Allocator

  @network """
  1 a
  2 b
  3 3a
  4 3b
  5 4c
  6 4a 3b 2c
  7 2a 2a 2b 2b
  8 2a2b
  """

  @matches """
  3b/n -> 3x4.1.b 3x6.2.b - 4x5.1.c
  4b/c -> 2x7.3.b 2x7.4.b - 3x6.2.b 2x6.3.c 4x5.1.c
  2c/n -> 2x6.3.c 4x5.1.c
  3a   -> 1.1.a 3x3.1.a 4x6.1.a 2x7.1.a 2x7.2.a 2x8.1.a - 2.1.b 3x4.1.b 3x6.2.b 2x7.3.b 2x7.4.b 2x8.1.b - 4x5.1.c 2x6.3.c
  c    -> 4x5.1.c 2x6.3.c
  """

  setup_all do
    %{bids: AllocatorHelpers.create_network(@network)}
  end

  @matches
  |> String.split("\n", trim: true)
  |> Enum.map(fn s ->
    @s s
    test "finds correct batches for ask #{inspect(@s)}", context do
      {ask, expected_result} = AllocatorHelpers.parse_test_data(@s)
      result = Allocator.allocate(ask, context.bids) |> AllocatorHelpers.batches_to_string()
      assert expected_result == result
    end
  end)
end
