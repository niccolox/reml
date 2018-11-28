defmodule Stage do
  use GenStage

  alias Reml.Env
  alias Reml.App.Store

  def start_link(task) do
    GenStage.start_link(__MODULE__, task)
  end

  def start_node(task, [bid]) do
    bid.node_id
    |> find_node()
    |> :rpc.call(Stage, :start_link, [task])
  end

  defp find_node(address) do
    Node.list()
    |> find_node(address)
  end

  defp find_node([], _), do: nil
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
    state = deploy_agent(task.agent)
    IO.inspect(state, label: "Starting at #{Node.self()}")
    {:producer_consumer, state}
  end

  defp deploy_agent(address) do
    with agent = Store.get_agent(address),
         {:ok, module} = Env.deploy_agent(address, agent.code)
    do
      module
    end
  end

  def handle_events(events, from, state) do
    IO.inspect(events, label: "Stage handling events from #{inspect from} on #{Node.self()}")
    IO.inspect(state, label: :state)
    results = Enum.map(events, &run_task(&1, state))
    {:noreply, results, state}
  end

  defp run_task(data, agent) do
    agent.run(data)
    |> IO.inspect(label: "Agent result")
  end
end
