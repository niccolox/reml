agent "{{address}}" do

  def construct(agent) do
    state = %{model: "./examples/square.pb"}
    set_state(state)
  end

  def handle("run", [x]) do
    model = get_value("model")

    input = %{
      "a" => Tensor.from_list([String.to_float(x)])
    }

    Flow.run(model, input)
    |> List.first()
    |> Float.to_string()
  end
end
