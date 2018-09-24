defmodule Pallium.App.Task.BidStorageTest do
  use ExUnit.Case

  alias PalliumCore.Core.Bid
  alias Pallium.App.Task.BidStorage

  test "saves bids" do
    bids = [
      %Bid{device_name: "A"},
      %Bid{device_name: "B"},
    ]
    Enum.each(bids, &BidStorage.add_bid/1)
    assert [] == bids -- BidStorage.get_bids()
  end
end
