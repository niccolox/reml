defmodule Pallium.App.State do
  @moduledoc false

  @initial_state %{last_block_height: 0, last_block_app_hash: ""}

  def start_link do
    Agent.start_link(fn -> @initial_state end, name: :pallium_app)
  end

  def get do
    Agent.get(:pallium_app, & &1)
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
    }
  end
end
