defmodule Pallium.App.ExchangeTest do
  use ExUnit.Case

  alias PalliumCore.Core.Bid
  alias Pallium.App.Exchange

  test "saves bids" do
    bids = [
      %Bid{device_name: "A"},
      %Bid{device_name: "B"},
    ]
    Enum.each(bids, &Exchange.add_bid/1)
    assert [] == bids -- Exchange.get_bids()
  end
end
