defmodule AgentHelpers do
  alias Myelin.Compiler
  alias Pallium.Core.Agent

  def random_address do
    {_, pubkey} = Crypto.gen_key_pair()
    pubkey
    |> Crypto.gen_address()
    |> Crypto.to_hex()
  end

  def agent_code(tmpl_name, address) do
    {:ok, code} = Compiler.compile_template(tmpl_name, address)
    code
  end

  def create(tmpl_name, address) do
    agent_code(tmpl_name, address)
    |> Helpers.to_hex()
    |> Agent.new()
    |> Agent.create(address, %{})
  end
end

