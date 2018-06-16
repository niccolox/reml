defmodule Helpers do
  @moduledoc """
  Helpers for common operations
  """
  @type keccak_hash :: binary()

  @spec keccak(binary()) :: keccak_hash
  def keccak(data), do: :keccakf1600.sha3_256(data)

  @spec from_hex(String.t()) :: binary()
  def from_hex(hex_data), do: Base.decode16!(hex_data, case: :lower)

  @spec to_hex(binary()) :: String.t()
  def to_hex(bin), do: Base.encode16(bin, case: :lower)

  def get_agent_code(address) do
    agent_atom = agent_atom = {:__aliases__, [alias: false], [String.to_atom(address)]}

    agent =
      quote do
        defmodule unquote(agent_atom) do
          #@behaviour Pallium.Env.AgentBehaviour
          def construct(_agent) do
            state = %{foo: "bar", hello: "Hello, world!"}
            Pallium.Env.set_state(_agent, state)
          end

          def handle(_agent, action, data) do
            case action do
              "foo" -> Pallium.Env.get_value(_agent, "foo")
              "hello" -> Pallium.Env.get_value(_agent, "hello")
            end
          end
        end
      end

    [{_, agent_code}] = Code.compile_quoted(agent)

    :code.purge(String.to_atom(address))
    :code.delete(String.to_atom(address))

    agent_code
  end
end
