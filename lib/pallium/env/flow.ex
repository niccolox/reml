defmodule Pallium.Env.Backends.Keras do
  @moduledoc """
  Documentation for Keras backend.
  """
  use Export.Python

  def call(function, args \\ []) do
    {:ok, py} = Python.start(python_path: Path.expand("priv/backends"))
    Python.call(py, "keras", function, args)
  end

end
