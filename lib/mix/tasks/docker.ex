defmodule Mix.Tasks.Docker do
  require Logger

  @tm_home "/root/.tendermint"
  @tm_genesis_file @tm_home <> "/config/genesis.json"
  @tm_config_file @tm_home <> "/config/config.toml"
  @tm_priv_validator_file @tm_home <> "/config/priv_validator.json"

  def stop_node(node) do
    docker(~w(stop #{node.name}), "Stopped node", node: node)
    # case docker(~w(stop #{name})) do
  end

  def rm_testnet do
    docker(~w(network rm testnet), "Removed test network")
  end

  def create_network do
    docker(~w(network create testnet), "Created test network")
  end

  def create_container(node) do
    lib_dir = Path.expand("lib")

    ~w(
      run --env-file config/docker.env \
      -v #{lib_dir}:/opt/app/lib \
      --expose #{node.port} \
      -p #{node.port}:8080 \
      --name #{node.name} \
      --net testnet \
      --hostname #{node.name} \
      --rm -d reml:latest
    )
    |> docker("Started container", node: node)
  end

  def init_tendermint(node) do
    ~w(exec #{node.name} /opt/tm/tendermint init)
    |> docker("Tendermint initialized", node: node)
  end

  def set_primary_node_id(node, primary_id) do
    node_id = get_node_address(node)

    run_cmd = """
      #!/bin/sh
      PRIMARY_NODE_ID=#{primary_id} iex --sname #{node_id} --cookie cookie -S mix
    """

    echo_cmd = "echo '#{run_cmd}' >> start_app.sh"

    ["exec", node.name, "sh", "-c", echo_cmd]
    |> docker("Set start app script", node: node)
  end

  def get_validator_key(node) do
    {:ok, result} =
      ~w(exec #{node.name} cat #{@tm_priv_validator_file})
      |> docker("Taken validator key", node: node)

    result
    |> Poison.decode!()
    |> Map.get("pub_key")
  end

  def send_genesis_file(node, file) do
    ["cp", file, "#{node.name}:#{@tm_genesis_file}"]
    |> docker("Updated genesis file", node: node)
  end

  def update_config(node, file) do
    ["cp", file, "#{node.name}:#{@tm_config_file}"]
    |> docker("Updated peers config", node: node)
  end

  def get_node_address(node) do
    cat_cmd =
      ~s(cat #{@tm_priv_validator_file} | grep '"address"' | sed 's/\\s*"address": "\\\([^"]*\\\)",/\\1/')

    {:ok, node_id} =
      ["exec", node.name, "sh", "-c", cat_cmd]
      |> docker("Got node id", node: node)

    node_id
  end

  def get_node_id(node) do
    {:ok, node_id} =
      ~w(exec #{node.name} /opt/tm/tendermint show_node_id)
      |> docker("Got node id", node: node)

    Map.put(node, :node_id, node_id)
  end


  defp docker(args, msg, opts \\ []) do
    case System.cmd("docker", args) do
      {result, 0} ->
        msg
        |> format(opts)
        |> Logger.info()

        {:ok, result |> String.trim_trailing("\n")}

      {out, code} ->
        cmd = "docker" <> Enum.join(args, " ")
        Logger.error(cmd <> " returned " <> inspect({out, code}))
        {:error, out}
    end
  end

  defp format(msg, []), do: msg
  defp format(msg, node: %{name: name}), do: "[#{name}] #{msg}"
end
