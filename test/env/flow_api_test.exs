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

    task = fn pid ->
      state = Wrapper.get_state(pid)
      buffer= if state.rank == 0 do
              data = 100
              Wrapper.broadcast(pid, data)
              data
      else
        Wrapper.get_buffer(pid)
      end
      IO.puts("Hello, my rank #{inspect state.rank} and my buffer: #{inspect buffer}")
      #IO.puts("Hello i,am #{inspect self()} my parrent is #{inspect pid} and my state #{inspect state}") 
    end

    {:ok, host} = Wrapper.start_link(task, 4)
    {:ok, w1}   = Wrapper.start_link(host)
    {:ok, w2}   = Wrapper.start_link(host)
    {:ok, w3}   = Wrapper.start_link(host)

    result_state = %{rank: 0, workers: [host, w1, w2, w3], size: 4, task: task, buffer: ""}

    assert Wrapper.get_state(host) == result_state   
    assert Wrapper.get_state(w1)   == %{result_state | rank: 0}
    assert Wrapper.get_state(w2)   == %{result_state | rank: 2}
    assert Wrapper.get_state(w3)   == %{result_state | rank: 3}
  end  
  
end
