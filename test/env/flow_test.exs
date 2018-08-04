defmodule FlowTest do
  use ExUnit.Case
  alias Pallium.Env.Flow
  doctest Flow

  test "should launch add model" do
    input = %{
      "a" => Extensor.Tensor.from_list([5]),
      "b" => Extensor.Tensor.from_list([5])
    }

    assert Flow.run("./examples/add.pb", input) == [10.0]
  end

  test "should launch square tf model" do
    input = %{
      "a" => Extensor.Tensor.from_list([5])
    }

    assert Flow.run("./examples/square.pb", input) == [25.0]
  end
end
