defmodule Pallium.Env.Flow.Model do
    use Export.Python
    alias Pallium.Env.Flow

    # Train model
    def fit(device_type, rank, model_hash, x_path, y_path, config) do
      args = [device_type, rank, model_hash, x_path, y_path, config]    
      result = Flow.call("fit", args)
      IO.inspect(result)
    end
    
end
