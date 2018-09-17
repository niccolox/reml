defmodule FlowTest do
  # Before starting the test, run IPFS: ipfs daemon --mount
  use ExUnit.Case

  alias Pallium.Env.Flow.{Model, Wrapper}

  #doctest Flow

  use ExUnit.Case, async: true
  
  @tag :skip
  setup_all do
    model  = IPFSApi.add_cmd("examples/mnist_keras/model.h5") |> IPFSApi.body
    images = IPFSApi.add_cmd("examples/mnist_keras/train_images.npy") |> IPFSApi.body
    labels = IPFSApi.add_cmd("examples/mnist_keras/train_labels.npy") |> IPFSApi.body

    [model: model["Hash"], images: images["Hash"], labels: labels["Hash"]]
  end
  
  @tag :skip
  test "start train model", context do
    config = [batch_size: 128]
    Model.fit("gpu", 0, context[:model], context[:images], context[:labels], config)
  end

  test "join wrapped tasks" do
    {:ok, host} = Wrapper.start_link
    {:ok, w1}   = Wrapper.start_link(host)
    {:ok, w2}   = Wrapper.start_link(host)
    {:ok, w3}   = Wrapper.start_link(host)

    assert Wrapper.get_state(host) == %{rank: 0, workers: [w1, w2, w3]}
    assert Wrapper.get_state(w1)   == %{rank: 1, workers: [host, w2, w3]}
    assert Wrapper.get_state(w2)   == %{rank: 2, workers: [host, w1, w3]}
    assert Wrapper.get_state(w3)   == %{rank: 3, workers: [host, w1, w2]}  
  end  

end
