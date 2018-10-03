defmodule Pallium.Env.Flow.Producer do
  @moduledoc false
  use GenStage
  
  alias Pallium.Env.Flow.Model

  def start_link(rank) do   
    state = %{
              rank: rank,
              model:  "examples/mnist_keras/model.h5",
              images: "examples/mnist_keras/train_images.npy",
              labels: "examples/mnist_keras/train_labels.npy"
    }

    GenStage.start_link(__MODULE__, state)
  end
  
  def train(pid, x, y) do
    GenStage.cast(pid, {:train, x, y})
  end  

  def init(state), do: {:producer, state}

  def handle_cast({:train, x, y}, state) do
    config = [batch_size: 128]
    Model.fit("gpu", state.rank, state.model, state.images, state.labels, config)
    events = [{:train, state.rank}]
    {:noreply, [events], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [:hello], state}
  end
