defmodule EnvTest do
  use ExUnit.Case
  doctest Pallium.Env

  test "loaded simple agent" do
    # name should be unique, later it will be the address of the agent
    agent_name = "PalliumAgent"
    agent_atom = agent_atom = {:__aliases__, [alias: false], [String.to_atom(agent_name)]}

    agent =
      quote do
        defmodule unquote(agent_atom) do
          @behaviour Pallium.Env.AgentBehaviour

          def construct() do
            :hello
          end
        end
      end

    [{PalliumAgent, object_code}] = Code.compile_quoted(agent)

    # unload module, it should be load in Pallium.Env
    :code.purge(PalliumAgent)
    :code.delete(PalliumAgent)

    assert Pallium.Env.deploy_agent(PalliumAgent, object_code) == :hello
  end
end
