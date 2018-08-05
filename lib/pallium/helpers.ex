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

  def pid_to_binary(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> :erlang.list_to_binary()
  end

  def pid_from_string(string) do
    string
    |> :erlang.binary_to_list()
    |> :erlang.list_to_pid()
  end

  def get_agent_code(address) do
    agent_atom = {:__aliases__, [alias: false], [String.to_atom(address)]}

    agent =
      quote do
        defmodule unquote(agent_atom) do
          # @behaviour Pallium.Env.AgentBehaviour
          @self unquote(address)

          def construct(agent) do
            state = %{foo: "bar", hello: "Hello, world!"}
            Pallium.Env.set_state(agent, state)
          end

          def handle(action, data) do
            case action do
              "foo" -> Pallium.Env.get_value(@self, "foo")
              "hello" -> @self |> Pallium.Env.get_value("hello") |> Pallium.Env.in_chan(@self)
            end
          end
        end
      end

    [{_, agent_code}] = Code.compile_quoted(agent)

    :code.purge(String.to_atom(address))
    :code.delete(String.to_atom(address))

    agent_code
  end

  def observer() do
    ob = fn f ->
      receive do
        {_, msg} ->
          IO.puts(msg)
          f.(f)
      end
    end

    spawn(fn -> ob.(ob) end)
  end
end
