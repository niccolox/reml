defmodule ChannelTest do
  use ExUnit.Case
  alias Pallium.Env.Channel
  doctest Channel

  test "send/recive channel message" do
    pid = Channel.open()

    assert send pid, {:ok, "hello"} == :hello
  end
end
