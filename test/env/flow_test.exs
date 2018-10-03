defmodule FlowTest do
  use ExUnit.Case

  alias Pallium.Env.Flow.{Producer, Consumer}

  test "connected" do
    size = 1
    {:ok, c} = Consumer.start_link(size)
    
    Enum.each(0..size-1, fn x ->
    {:ok, w} = Producer.start_link(x)
    GenStage.sync_subscribe(c, to: w)
    end)

    Process.sleep(50000)
  end
end
