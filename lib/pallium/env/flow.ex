defmodule Pallium.Env.Flow do
  @moduledoc """
  Documentation for TendorFlow models API.
  """
  use Export.Python
  alias Extensor.{Session, Tensor}

  def python_call(function, args \\ []) do
    {:ok, py} = Python.start(python_path: Path.expand("priv"))
    Python.call(py, "flow_api", function, args)
  end

  #This function is obsolete, in future, it will be deleted
  def run(filename, input) do
    session = Session.load_frozen_graph!(filename)
    output = Session.run!(session, input, ["c"])

    Tensor.to_list(output["c"])
  end
end
