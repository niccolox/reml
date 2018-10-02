defmodule Mix.Tasks.Testnet do
  @shortdoc "Create testnet in docker containers"
  @moduledoc """
  Creates docker containers for testnet

  ## Usage:

  mix testnet start - create containers for each node

  mix testnet stop  - stop all containers
  """

  use Mix.Task

  require Logger

  alias Mix.Tasks.Docker

  @nodes [
    %{port: 11122, name: "node1"},
    %{port: 11123, name: "node2"},
    %{port: 11124, name: "node3"},
    %{port: 11125, name: "node4"},
  ]

  def run(["stop"]) do
    async_nodes &Docker.stop_node/1
    Docker.rm_testnet()
  end

  def run(["start"]) do
    Docker.create_network()
    async_nodes &Docker.create_container/1
    async_nodes &Docker.init_tendermint/1
    update_genesis_file()
    update_peers()
  end

  defp async_nodes(task) do
    @nodes
    |> Enum.map(&Task.async(fn -> task.(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp update_genesis_file do
    genesis_file =
      @nodes
      |> Enum.map(&Docker.get_validator_key/1)
      |> Enum.map(&(%{name: "", power: "10", pub_key: &1}))
      |> Poison.encode!()
      |> build_genesis_file()

    async_nodes &Docker.send_genesis_file(&1, genesis_file)

    File.rm!(genesis_file)
  end

  defp build_genesis_file(validators) do
    "genesis.json"
    |> read_template()
    |> String.replace("{{validators}}", validators)
    |> write_temp_file()
  end

  defp update_peers do
    config_file =
      "config.toml"
      |> read_template()
      |> String.replace("{{peers}}", get_peers())
      |> write_temp_file()

    async_nodes &Docker.update_config(&1, config_file)

    File.rm!(config_file)
  end

  defp get_peers do
    async_nodes(&Docker.get_node_id/1)
    |> Enum.map(fn node -> "#{node.node_id}@#{node.name}:26656" end)
    |> Enum.join(",")
  end

  defp read_template(filename) do
    :pallium
    |> :code.priv_dir()
    |> Path.join("tendermint/" <> filename)
    |> File.read!()
  end

  defp write_temp_file(content) do
    filename = Temp.path!()
    File.write!(filename, content)
    filename
  end

end
