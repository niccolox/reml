defmodule WrapperTest do
  use ExUnit.Case

  alias Pallium.Env.Flow.{Wrapper, Consumer}
 
  test "connected" do
    task = fn input -> 
      rand = :rand.uniform(1000)
      Process.sleep(rand) 
      rand
    end
    size = 4
    {:ok, c} = Consumer.start_link(size)

    Enum.each(0..size, fn _ -> 
      {:ok, w} = Wrapper.start_link(task)
      GenStage.sync_subscribe(c, to: w)
    end)

    Process.sleep(5000)
  end
end
