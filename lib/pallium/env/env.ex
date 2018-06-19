defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  alias Pallium.Myelin.Agent
  alias Pallium.Env.Flow

  def deploy_agent(address, code) do
    agent = String.to_existing_atom("Elixir.#{address}")
    case :code.load_binary(agent, 'nofile', code) do
      {:module, module_name} -> module_name
      {:error, reason} -> {:error, reason}
    end
  end

  def dispatch(agent, state, address, method, data) do
     case method do
       "CONSTRUCT" -> agent.construct(address)
       "MESSAGE" -> {:ok, agent.handle(address, data.action, data.data)}
     end
  end

  def set_state(address, state) do
    Agent.set_state(address, state)
  end

  def get_value(address, key) do
    Agent.get_state(address, key)
  end
end
