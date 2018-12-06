defmodule Stage do
  use GenStage

  alias PalliumCore.Crypto
  alias Reml.App.Store
  alias Reml.Env

  def start_link(task) do
    GenStage.start_link(__MODULE__, task)
  end

  def start_node(task, [bid]) do
    bid.node_id
    |> Crypto.to_hex()
    |> String.upcase()
    |> find_node()
    |> :rpc.call(Stage, :start_link, [task])
  end

  defp find_node(address) do
    Node.list()
    |> find_node(address)
  end

  defp find_node([], address), do: raise("Node #{address} not found")
  defp find_node([node | rest], address) do
    node
    |> Atom.to_string()
    |> String.contains?(address)
    |> case do
      true -> node
      false -> find_node(rest, address)
    end
  end

  def init(task) do
    state = deploy_agent(task.to)
    {:producer_consumer, state}
  end

  defp deploy_agent(address) do
    with agent = Store.get_agent(address),
         {:ok, module} = Env.deploy_agent(address, agent.code)
    do
      module
    end
  end

  def handle_events(events, _from, state) do
    results = Enum.map(events, &run_task(&1, state))
    {:noreply, results, state}
  end

  defp run_task(data, agent) do
    agent.run(data)
  end
end
