defmodule Pallium.Env.Flow do
  @moduledoc """
  Documentation for TendorFlow models launcher.
  """
  def run(filename, input) do
    session = Extensor.Session.load_frozen_graph!(filename)
    output = Extensor.Session.run!(session, input, ["c"])

    Extensor.Tensor.to_list(output["c"])
  end
end
