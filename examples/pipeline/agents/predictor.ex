defmodule Pallium.Examples.Pipeline.Predictor do
  @moduledoc false
  use GenStage

  alias Pallium.Env.Backends.Keras

  def start_link() do
    GenStage.start_link(__MODULE__, [])
  end

  def prediction(data) do
    GenStage.cast(pid, {:prediction, data})
  end

  def init(state), do: {:producer, state}

  def handle_cast({:prediction, data}, state) do
    {:noreply, [], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [:hello], state}
  end
end
