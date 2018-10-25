defmodule AgentHelpers do
  alias PalliumCore.Compiler
  alias PalliumCore.Crypto
  alias PalliumCore.Core.Agent
  alias Reml.App.AgentController

  def random_address do
    {_, pubkey} = Crypto.gen_key_pair()
    pubkey
    |> Crypto.gen_address()
    |> Crypto.to_hex()
  end

  def agent_code(tmpl_name, address) do
    {:ok, code} = Compiler.compile_agent(tmpl_name, address)
    code
  end

  def create(tmpl_name, address) do
    code =
      agent_code(tmpl_name, address)
    %Agent{code: code}
    |> AgentController.create(address, %{})
  end
end

