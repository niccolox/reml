defmodule Reml.Env.Utils.Image do
  use Export.Python

  def to_vector(filename) do
    {:ok, py} = Python.start(python_path: Path.expand("python"))
    Python.call(py, "img_to_vector", "process", [filename])
  end
end
