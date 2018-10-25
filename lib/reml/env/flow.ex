defmodule Reml.Env.Flow do
  @moduledoc """
  Documentation for TendorFlow models API.
  """
  use Export.Python

  def call(function, args \\ []) do
    {:ok, py} = Python.start(python_path: Path.expand("priv"))
    Python.call(py, "flow_api", function, args)
  end

end
