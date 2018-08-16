defmodule Pallium.Application do
  @moduledoc false

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: AgentProcessSupervisor}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
