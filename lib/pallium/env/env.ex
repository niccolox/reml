defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  alias Pallium.Core.Agent
  alias Pallium.Env.Channel

  require Logger
  require IEx

  def deploy_agent(address, code) do
    agent = String.to_atom(address)

    case :code.load_binary(agent, 'nofile', code) do
      {:module, module_name} -> {:ok, module_name}
      {:error, reason} -> {:error, reason}
    end
  end

  def dispatch(agent, _state, _address, :construct, params) do
    {:ok, agent.construct(params)}
  end

  def dispatch(agent, state, address, :message, %{action: action, data: data}) do
    try do
      {:ok, agent.action(to_string(action), data)}
    rescue
      e ->
        Logger.error("Error in agent action: #{inspect e}")
        Agent.set_state_root_hash(address, state)
        {:error, e}
    end
  end

  def set_state(address, state) do
    Agent.set_state(address, state)
  end

  def get_value(address, key) do
    Agent.get_state_value(address, key)
  end

  def set_value(address, key, value) do
    Agent.put_state(address, key, value)
  end

  def start_process(_address, fun) do
    Task.Supervisor.async_nolink(AgentProcessSupervisor, fun)
  end

  def to_chan(msg, chan) do
    send chan, msg
  end

  def connect(who, channel) do
    send channel, {:connect, who}
  end

  def open_channel(owner) do
    Channel.open(owner)
  end
end
