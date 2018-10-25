defmodule Reml.Tendermint.Node do
  use Agent

  alias PalliumCore.Crypto

  @node_config Application.get_env(:reml, :tendermint_priv_validator)

  def start_link(_) do
    node_cfg =
      @node_config
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    state =
      %{
        address: node_cfg["address"] |> String.downcase() |> Crypto.from_hex(),
        priv_key: node_cfg["priv_key"]["value"],
        pub_key: node_cfg["pub_key"]["value"],
      }
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def address, do: Agent.get(__MODULE__, fn state -> state.address end)

  def priv_key, do: Agent.get(__MODULE__, fn state -> state.priv_key end)

  def pub_key, do: Agent.get(__MODULE__, fn state -> state.pub_key end)

end
