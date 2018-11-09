defmodule Reml.Env.Docker do
  require Logger

  def copy(cid, path, dest) do
    ~w(cp #{path} #{cid}:#{dest})
    |> docker("Copying file #{path}")
  end

  def start_container(context) do
    {:ok, "sha256:" <> image} = build_image(context)
    port = find_free_port()
    {:ok, container_id} =
      ~w(run -itd -p #{port}:9090 #{image})
      |> docker("Starting docker container")
    {container_id, port}
    |> IO.inspect(label: :docker_container)
  end

  defp build_image(context) do
    ~w(build -q #{context})
    |> docker("Building docker image")
    |> IO.inspect(label: "built image")
  end

  def stop_container(cid) do
    ~w(stop #{cid})
    |> docker("Stopping container")
  end

  # FIXME: find actually free port
  defp find_free_port, do: Enum.random(1024..9999)

  def cp(cid, filename) do
    cont_path = Path.basename(filename)
    ~w(cp #{filename} #{cid}:/root/#{cont_path})
    |> docker("Copying file #{filename}")
    cont_path
  end

  def exec(cmd) do
    ["exec", [cmd]]
    |> List.flatten()
    |> docker("Executing cmd #{inspect cmd}")
  end

  defp docker(args, msg, opts \\ []) do
    msg
    |> format(opts)
    |> Logger.info()
    case System.cmd("docker", args) do
      {result, 0} ->
        {:ok, result |> String.trim_trailing("\n")}
      {out, code} ->
        cmd = "docker " <> Enum.join(args, " ")
        Logger.error(cmd <> " returned " <> inspect({out, code}))
        {:error, out}
    end
  end

  defp format(msg, []), do: msg
  defp format(msg, [node: %{name: name}]), do: "[#{name}] #{msg}"
end
