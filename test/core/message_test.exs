defmodule MessageTest do
  use ExUnit.Case
  alias Pallium.Core.Message
  doctest Message

  test "should return new RLP encoded message struct" do
    message = Message.new("foo", "bar")
    assert Message.decode(message) == %Message{action: "foo", props: "bar"}
  end
end
