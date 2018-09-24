defmodule Pallium.App.Task.BidRate do
  @moduledoc """
  Calculates rationality of fulfiling ask with given bid

  Rates:
  0 - when bid is not suitable for the ask
  1 - when bid is exactly matches the ask
  > 1 - when bid is more powerful then ask
  """

  alias PalliumCore.Core.Ask
  alias PalliumCore.Core.Bid

  def rate(%Ask{} = ask, %Bid{} = bid) do
    rate_dev_type(ask, bid) * rate_dev_desc(ask, bid) * rate_memory(ask, bid)
  end

  defp rate_dev_type(ask, bid) do
    case {ask.device_type, bid.device_type} do
      {:cpu, :gpu} -> 2
      {:gpu, :cpu} -> 0
      _ -> 1
    end
  end

  defp rate_dev_desc(ask, bid) do
    case String.contains?(bid.device_desc, ask.device_desc) do
      true -> 1
      false -> 0
    end
  end

  defp rate_memory(ask, bid) do
    cond do
      ask.min_memory > bid.memory_limit -> 0
      ask.min_memory > 0 -> bid.memory_limit / ask.min_memory
      true -> 1
    end
  end
end
