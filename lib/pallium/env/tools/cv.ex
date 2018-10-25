defmodule Pallium.Env.Tools.CV do
  @moduledoc false
  use Export.Python

  def imdecode(raw) do
    __MODULE__.call("imdecode", [raw])
  end

  def call(function, args \\ []) do
    {:ok, py} = Python.start(python_path: Path.expand("priv/tools"))
    Python.call(py, "cv", function, args)
  end
end
