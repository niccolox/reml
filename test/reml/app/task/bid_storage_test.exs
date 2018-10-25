defmodule Reml.App.Task.BidStorageTest do
  use ExUnit.Case

  alias PalliumCore.Core.Bid
  alias Reml.App.Task.BidStorage

  test "saves bids" do
    bids = [
      %Bid{device_name: "A"},
      %Bid{device_name: "B"},
    ]
    Enum.each(bids, &BidStorage.add_bid/1)
    assert [] == bids -- BidStorage.get_all()
  end
end
