defmodule Reml.Env do
  @moduledoc """
  Documentation for Reml Environment.
  """
  alias Reml.Env.Channel
  alias Reml.App.State
  alias Reml.App.Store
  alias Reml.App.Task
  alias Reml.App.Task.TaskController
  alias PalliumCore.Compiler

  require Logger
  require IEx

  def deploy_agent(address, code) do
    :ok = Compiler.load_agent_modules(code)
    {:ok, String.to_atom(address)}
  end

  def dispatch(agent, _state, _address, :construct, params) do
    {:ok, agent.construct(params)}
  end

  def dispatch(agent, state, address, :message, %{action: action, data: data}) do
    try do
      {:ok, agent.run([action, data])}
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

  def local_path(path), do: Path.join("fs", path)

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
