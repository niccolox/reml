defmodule AllocatorHelpers do
  alias PalliumCore.Core.Ask
  alias PalliumCore.Core.Bid

  def create_network(network) do
    network
    |> String.split("\n", trim: true)
    |> Enum.map(&create_cluster/1)
    |> List.flatten()
  end

  def create_cluster(data) do
    [cluster_id, cluster_data] = String.split(data, " ", parts: 2, trim: true)
    cluster_data
    |> String.split(" ", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(&create_node(&1, cluster_id))
  end

  def create_node({data, node_id}, cluster_id) do
    ~r/(\d)?(\w)/
    |> Regex.scan(data, capture: :all_but_first)
    |> Enum.map(fn [n, type] ->
      create_bid(type, node_id, cluster_id)
      |> List.duplicate(parse_num(n))
    end)
  end

  defp parse_num(""), do: 1
  defp parse_num(s), do: String.to_integer(s)

  def create_bid(type, node_id, cluster_id) do
    %Bid{bid_base(type) | node_id: node_id, cluster_id: cluster_id, device_name: type}
  end

  def bid_base("a"), do: %Bid{device_type: :cpu, memory_limit: 1000}
  def bid_base("b"), do: %Bid{device_type: :cpu, memory_limit: 2000}
  def bid_base("c"), do: %Bid{device_type: :gpu, memory_limit: 4000}

  def parse_test_data(data) do
    [ask_data, results_data] = String.split(data, ~r/\s+->\s+/)
    ask = create_ask(ask_data)
    expected_results = parse_expected_results(results_data)
    {ask, expected_results}
  end

  def create_ask(data) do
    {num, type, mode} =
      case Regex.run(~r/(\d+)?(\w)(\/(\w))?/, data, capture: :all_but_first) do
        [n, t, _, m] -> {n, t, m}
        [n, t] -> {n, t, :any}
      end

    %Ask{ ask_base(type) |
      num_devices: parse_num(num),
      same_node: mode == "n",
      same_cluster: mode == "c",
    }
  end

  def ask_base("a"), do: %Ask{device_type: :cpu, min_memory: 1000}
  def ask_base("b"), do: %Ask{device_type: :cpu, min_memory: 2000}
  def ask_base("c"), do: %Ask{device_type: :gpu, min_memory: 4000}

  def parse_expected_results(data) do
    data
    |> String.split(" - ")
    |> Enum.map(&parse_batch_results/1)
    |> Enum.join(" - ")
  end

  def parse_batch_results(data) do
    data
    |> String.split(" ")
    |> Enum.map(&expand_node_description/1)
    |> Enum.sort()
    |> Enum.join(" ")
  end

  defp expand_node_description(str) do
    case Regex.run(~r/(\d+)x([^\s]+)/, str, capture: :all_but_first) do
      [n, s] -> List.duplicate(s, String.to_integer(n)) |> Enum.join(" ")
      _ -> str
    end
  end

  def batches_to_string(batches) do
    batches
    |> Enum.map(&batch_to_string/1)
    |> Enum.join(" - ")
  end

  def batch_to_string(batch) do
    batch
    |> Enum.map(&bid_to_string/1)
    |> Enum.sort()
    |> Enum.join(" ")
  end

  def bid_to_string(bid) do
    [bid.cluster_id, bid.node_id, bid.device_name]
    |> Enum.join(".")
  end
end
