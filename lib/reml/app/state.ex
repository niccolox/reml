defmodule Reml.App.State do
  @moduledoc false

  use Agent

  @initial_state %{last_block_height: 0, last_block_app_hash: ""}

  def start_link([]) do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def last_block_height do
    Agent.get(__MODULE__, &(&1.last_block_height))
  end
end
