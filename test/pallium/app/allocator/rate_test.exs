defmodule Pallium.App.Allocator.RateTest do
  use ExUnit.Case

  alias PalliumCore.Core.Ask
  alias PalliumCore.Core.Bid
  alias Pallium.App.Allocator.Rate

  test "rates bids" do
    ask = %Ask{min_memory: 1000, device_type: :cpu}
    assert 0 == Rate.rate(ask, %Bid{memory_limit: 900, device_type: :cpu})
    assert 1 == Rate.rate(ask, %Bid{memory_limit: 1000, device_type: :cpu})
    assert 1 < Rate.rate(ask, %Bid{memory_limit: 1000, device_type: :gpu})
    assert 1 < Rate.rate(ask, %Bid{memory_limit: 1100, device_type: :cpu})
  end

  test "rates better bid with better ratio" do
    ask = %Ask{min_memory: 1000, device_type: :cpu}
    r1 = Rate.rate(ask, %Bid{memory_limit: 1100, device_type: :cpu})
    r2 = Rate.rate(ask, %Bid{memory_limit: 1600, device_type: :cpu})
    r3 = Rate.rate(ask, %Bid{memory_limit: 1100, device_type: :gpu})
    assert r1 < r2
    assert r1 < r3
  end
end
