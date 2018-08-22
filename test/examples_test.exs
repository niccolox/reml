defmodule ExamplesTest do
  use ExUnit.Case

  test "should recognize the panda" do
    img_as_list = Matrex.load("examples/inception/panda.csv") |> Matrex.to_list()
    float_to_int = Enum.map(img_as_list, fn(y) -> Kernel.trunc(y) end)
    list_to_format = Enum.chunk_every(float_to_int, 3) |> Enum.chunk_every(100)

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
