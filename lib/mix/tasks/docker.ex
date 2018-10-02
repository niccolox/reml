defmodule Mix.Tasks.Docker do

  require Logger

  @tm_home "/root/.tendermint"
  @tm_genesis_file @tm_home <> "/config/genesis.json"
  @tm_config_file @tm_home <> "/config/config.toml"
  @tm_priv_validator_file @tm_home <> "/config/priv_validator.json"

  def stop_node(%{name: name}) do
    docker(~w(stop #{name}), "Stopped node #{name}")
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
      --expose #{node.port} -p #{node.port}:8080 \
      --name #{node.name} \
      --net testnet \
      --hostname #{node.name} \
      --rm -d pallium:latest
    )
    |> docker("Started container #{node.name}")
  end

  def init_tendermint(node) do
    ~w(exec #{node.name} /opt/tm/tendermint init)
    |> docker("Tendermint initialized")
  end

  def get_validator_key(node) do
    {:ok, result} =
      ~w(exec #{node.name} cat #{@tm_priv_validator_file})
      |> docker("Taken validator key from #{node.name}")
    result
    |> Poison.decode!()
    |> Map.get("pub_key")
  end

  def send_genesis_file(node, file) do
    ["cp", file, "#{node.name}:#{@tm_genesis_file}"]
    |> docker("Updated genesis file at #{node.name}")
  end

  def update_config(node, file) do
    # sed = ~s(sed -i 's/persistent_peers = ""/persistent_peers = "#{peers}"/' #{@tm_config_file})
    # ["exec", "-i", node.name, "sh", "-c", sed]
    ["cp", file, "#{node.name}:#{@tm_config_file}"]
    |> docker("Updated peers config at #{node.name}")
  end

  def get_node_id(node) do
    {:ok, node_id} =
      ~w(exec #{node.name} /opt/tm/tendermint show_node_id)
      |> docker("Got node id from #{node.name}")
    Map.put(node, :node_id, node_id)
  end

  defp docker(args, msg) do
    # Logger.debug "docker #{args |> Enum.join(" ")}"
    case System.cmd("docker", args) do
      {result, 0} ->
        Logger.info(msg)
        {:ok, result |> String.trim_trailing("\n")}
      {out, code} ->
        cmd = "docker" <> Enum.join(args, " ")
        Logger.error(cmd <> " returned " <> inspect({out, code}))
        {:error, out}
    end
  end
end
