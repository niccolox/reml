defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  def delpoy_agent(agent, object_code) do
    :code.load_binary(agent, '', object_code)
    agent.hello()
  end
end
