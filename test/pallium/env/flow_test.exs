defmodule Pallium.Env.FlowTest do
  use ExUnit.Case

  alias Extensor.Tensor
  alias Pallium.Env.Flow

  doctest Flow

  test "should launch add model" do
    input = %{
      "a" => Tensor.from_list([5]),
      "b" => Tensor.from_list([5])
    }

    assert Flow.run("./examples/add.pb", input) == [10.0]
  end

  test "should launch square tf model" do
    input = %{
      "a" => Tensor.from_list([5])
    }

    assert Flow.run("./examples/square.pb", input) == [25.0]
  end
end
