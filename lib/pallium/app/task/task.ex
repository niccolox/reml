defmodule Pallium.App.Task do
  alias PalliumCore.Core.Ask
  alias Pallium.App.State
  alias Pallium.App.Task

  use PalliumCore.Struct,
    from: "",
    to: "",
    task: "",
    status: :unassigned,
    created_at: 0,
    params: []

  def age(%Task{created_at: created_at}) do
    State.last_block_height() - created_at
  end

  # TODO: this function intended to read requirements for given task from agent's state
  def ask(%Task{}) do
    %Ask{}
  end
end
