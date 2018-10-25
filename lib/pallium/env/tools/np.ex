defmodule Pallium.Env.Tools.NP do
  @moduledoc false
  use Export.Python

  def fromstring(raw) do
    __MODULE__.call("fromstring", [raw])
  end

  def call(function, args \\ []) do
    {:ok, py} = Python.start(python_path: Path.expand("priv/tools"))
    Python.call(py, "np", function, args)
  end
end
