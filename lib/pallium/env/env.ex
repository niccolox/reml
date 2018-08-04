defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  alias Pallium.Core.Agent

  def deploy_agent(address, code) do
    agent = String.to_atom("Elixir.#{address}")

    case :code.load_binary(agent, 'nofile', code) do
      {:module, module_name} -> module_name
      {:error, reason} -> {:error, reason}
    end
  end

  def dispatch(agent, _state, address, method, props) do
    case method do
      :construct -> agent.construct(address)
      :message -> {:ok, agent.handle(props.action, props.data)}
    end
  end

  def to_process(address, props) do
    agent = String.to_existing_atom("Elixir.#{address}")

    state = agent.will_deploy()
    pid = spawn(agent, :deploy, [state, props])

    pid |> Helpers.pid_to_binary()
  end

  def set_state(address, state) do
    Agent.set_state(address, state)
  end

  def get_value(address, key) do
    Agent.get_state(address, key)
  end

  def set_value(address, key, value) do
    Agent.put_state(address, key, value)
  end

  def to_chan(msg, chan) do
    send chan, msg
  end

  def connect(who, channel) do
    send channel, {:connect, who}
  end

  def open_channel(owner) do
    Pallium.Env.Channel.open(owner)
  end
end
