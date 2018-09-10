defmodule FlowTest do
  # Before starting the test, run IPFS: ipfs daemon --mount
  use ExUnit.Case

  alias Pallium.Env.Flow.{Model}

  #doctest Flow

  use ExUnit.Case, async: true

  setup_all do
    model  = IPFSApi.add_cmd("examples/mnist_keras/model.h5") |> IPFSApi.body
    images = IPFSApi.add_cmd("examples/mnist_keras/train_images.npy") |> IPFSApi.body
    labels = IPFSApi.add_cmd("examples/mnist_keras/train_labels.npy") |> IPFSApi.body

    [model: model["Hash"], images: images["Hash"], labels: labels["Hash"]]
  end

  test "start train model", context do
    Model.fit(context[:model], context[:images], context[:labels])
  end

end
