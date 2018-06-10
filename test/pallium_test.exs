defmodule PalliumTest do
  use ExUnit.Case
  doctest Pallium

  test "greets the world" do
    assert Pallium.hello() == :world
  end
end
