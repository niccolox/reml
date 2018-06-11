defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  def deploy_agent(address, object_code) do
    agent = String.to_existing_atom("Elixir.#{address}")
    :code.load_binary(agent, 'nofile', object_code)
  end

  def dispatch(agent, data) do
    agent.construct()
  end
end
