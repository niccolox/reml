defmodule Pallium.Env.AgentBehaviour do
  @callback construct() :: :hello
  @callback get_message() :: nil
  @callback will_deploy() :: nil
  @callback deploy() :: nil
  @callback did_deploy() :: nil
end
