defmodule FlowTest do
  use ExUnit.Case
  alias Pallium.Env.Flow
  doctest Flow

  test "should launch tf model" do
    input = %{
      "a" => Extensor.Tensor.from_list([3, 5]),
      "b" => Extensor.Tensor.from_list([4, 12])
    }
    assert Flow.run("./examples/graph.pb", input) == [5.0, 13.0]
  end
end
