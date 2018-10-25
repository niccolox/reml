defmodule Pallium.Examples.Pipeline.EventHandler do
  @moduledoc false
  use GenStage

  alias Pallium.Env.Flow.Model
  alias Pallium.Env.Tools.{CV, NP}

  def start_link() do
    GenStage.start_link(__MODULE__, [])
  end

  def request(raw) do
    GenStage.cast(pid, {:request, raw})
  end

  def init(state), do: {:producer, state}

  def handle_cast({:request, raw}, state) do
    event =
      raw
        |> String.split(",")
        |> List.last
        |> Base.decode64
        |> CV.raw_to_rgb(raw)
    {:noreply, [event], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [:hello], state}
  end
end
