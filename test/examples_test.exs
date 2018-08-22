defmodule ExamplesTest do
  use ExUnit.Case

  test "should recognize the panda" do
    list_to_format =
      "examples/inception/panda.csv"
      |> Matrex.load()
      |> Matrex.to_list()
      |> Enum.map(&Kernel.trunc/1)
      |> Enum.chunk_every(3)
      |> Enum.chunk_every(100)

    session = Extensor.Session.load_frozen_graph!("examples/inception/classify_image_graph_def.pb")

    input = %{
      "DecodeJpeg" => Extensor.Tensor.from_list(list_to_format, :uint8)
    }

    output = Extensor.Session.run!(session, input, ["softmax"])
    result = Extensor.Tensor.to_list(output["softmax"]) |> List.flatten()
    max_prob = Enum.max(result)

    assert Enum.find_index(result, fn(x) -> x == max_prob end) == 169
  end

end
