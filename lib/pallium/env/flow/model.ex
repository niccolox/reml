defmodule Pallium.Env.Flow.Model do
    use Export.Python

    # Train model
    def fit() do
      {:ok, py} = Python.start(python_path: Path.expand("priv"))
      result = py |> Python.call("flow_api", "fit", [])
      IO.inspect(result)
    end
end
