defmodule Docker do
  require Logger

  def run_in_container(name, block) do
    {cid, _} = cnt = start_container(name)
    result = block.(cnt)
    stop_container(cid)
    result
  end

  defp start_container(name) do
    port = find_free_port()
    {:ok, container_id} =
      ~w(run -itd -p #{port}:9090 #{name})
      |> docker("Docker container started")
    {container_id, port}
    |> IO.inspect(label: :docker_container)
  end

  defp stop_container(cid) do
    ~w(stop #{cid})
    |> docker("Stopped container")
  end

  # FIXME: find actually free port
  defp find_free_port, do: Enum.random(1024..9999)

  def cp(cid, filename) do
    cont_path = Path.basename(filename)
    ~w(cp #{filename} #{cid}:/root/#{cont_path})
    |> docker("Copied file #{filename}")
    cont_path
  end

  def exec(cmd) do
    ["exec", [cmd]]
    |> List.flatten()
    |> docker("Executed cmd #{inspect cmd}")
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
  defp format(msg, [node: %{name: name}]), do: "[#{name}] #{msg}"
end
