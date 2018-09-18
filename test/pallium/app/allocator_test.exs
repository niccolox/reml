defmodule Pallium.App.AllocatorTest do
  use ExUnit.Case

  alias Pallium.App.Allocator

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
    test "finds correct bids for in #{inspect @s}", context do
      {ask, expected_result} = AllocatorHelpers.parse_test_data(@s)
      result = Allocator.allocate(ask, context.bids) |> AllocatorHelpers.batches_to_string()
      assert expected_result == result
    end
  end)
end
