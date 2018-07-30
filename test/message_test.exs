defmodule MessageTest do
  use ExUnit.Case
  alias Pallium.Myelin.Message
  doctest Message

  test "create message" do
    message = Message.create("foo", "bar")
    assert Message.decode(message) == %Message{action: "foo", data: "bar"}
  end
end
