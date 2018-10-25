defmodule Reml.Env.Flow.System do
  alias Reml.Env.Flow

  def devices() do
    devices = Flow.call("devices")
    devices |> Enum.map(&get_device_map/1)
  end

  defp get_device_map(device) do
    [name, type, memory] = device
    %{name: "#{name}", type: "#{type}", memory: "#{memory}"}
  end
end
