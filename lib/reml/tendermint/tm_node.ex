defmodule Reml.Tendermint.TMNode do
  use Agent

  alias PalliumCore.Crypto

  require Logger

  @node_config Application.get_env(:reml, :tendermint_priv_validator)

  def start_link(_) do
    %{
      "address" => address,
      "priv_key" => priv_key,
      "pub_key" => pub_key
    } =
      @node_config
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    connect_to_master_node(System.get_env("PRIMARY_NODE_ID"), address)
    |> case do
      false -> Logger.warn("Could not connect to masternode")
      _ -> :ok
    end

    state = %{
      address: address |> String.downcase() |> Crypto.from_hex(),
      priv_key: priv_key["value"],
      pub_key: pub_key["value"]
    }

    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def address, do: Agent.get(__MODULE__, fn state -> state.address end)

  def priv_key, do: Agent.get(__MODULE__, fn state -> state.priv_key end)

  def pub_key, do: Agent.get(__MODULE__, fn state -> state.pub_key end)

  defp connect_to_master_node(nil, _), do: :no_masternode
  defp connect_to_master_node(master_node_id, master_node_id), do: :i_am_masternode

  defp connect_to_master_node(master_node_id, _current_node_id) do
    (master_node_id <> "@node1")
    |> String.to_atom()
    |> Node.connect()
  end
end
