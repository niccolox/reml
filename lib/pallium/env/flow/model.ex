defmodule Pallium.Env.Flow.Model do
    use Export.Python

    # Train model
    def fit(model_hash, x_path, y_path) do
      {:ok, py} = Python.start(python_path: Path.expand("priv"))
      result = py |> Python.call("flow_api", "fit", [model_hash, x_path, y_path])
      IO.inspect(result)
    end
end
