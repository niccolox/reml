defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  alias Pallium.Myelin.Store

  def deploy_agent(address, object_code) do
    agent = String.to_existing_atom("Elixir.#{address}")
    :code.load_binary(agent, 'nofile', object_code)
  end

  def dispatch(agent, state) do
    agent.construct()
  end

  # def set_state(state)
  #   Store.set_state(state)
  # end
  #
  # def get_value(key)
  #   Store.get_state()
  # end
end
