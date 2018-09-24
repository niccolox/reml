defmodule FlowTest do
  use ExUnit.Case

  alias Pallium.Env.Flow.{Producer, Consumer}
 
  test "connected" do
    size = 4
    {:ok, c} = Consumer.start_link(size)

    Enum.each(0..size, fn _ -> 
      {:ok, w} = Producer.start_link()
      GenStage.sync_subscribe(c, to: w)
    end)

    Process.sleep(5000)
  end
end
