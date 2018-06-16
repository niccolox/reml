defmodule MessageTest do
  use ExUnit.Case
  alias Pallium.Myelin.Message
  doctest Message
  @address "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"

  test "create message" do
    message = Message.create(@address, "foo", "bar")
    assert Message.decode(message) == %Message{action: "foo", address: @address, data: "bar"}
  end
end
