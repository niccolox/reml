defmodule Reml.App.Task do
  alias PalliumCore.Core.Ask
  alias Reml.App.State
  alias Reml.App.Task

  use PalliumCore.Struct,
    from: "",
    to: "",
    task: "",
    pipeline: "",
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
