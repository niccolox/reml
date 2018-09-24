defmodule Pallium.Env do
  @moduledoc """
  Documentation for Pallium Environment.
  """
  alias Pallium.Env.Channel
  alias Pallium.App.State
  alias Pallium.App.Store
  alias Pallium.App.Task
  alias Pallium.App.Task.TaskController

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
        Store.reset_state_hash(address, state)
        {:error, e}
    end
  end

  def get_value(address, key) do
    Store.get_state_value!(address, key)
  end

  def set_value(address, key, value) do
    Store.update_state_value!(address, key, value)
  end

  def set_state(address, map) do
    Store.set_state(address, map)
  end

  def start_task(from, to, task) do
    %Task{
      from: from,
      to: to,
      task: task,
      created_at: State.last_block_height(),
    }
    |> TaskController.add_task()
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
