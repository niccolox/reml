defmodule Pallium.Env.Flow do
  @moduledoc """
  Documentation for TendorFlow models launcher.
  """

  alias Extensor.{Session, Tensor}

  def run(filename, input) do
    session = Session.load_frozen_graph!(filename)
    output = Session.run!(session, input, ["c"])

    Tensor.to_list(output["c"])
  end
end
