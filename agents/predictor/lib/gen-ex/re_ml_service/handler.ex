defmodule(ReMLService.Handler) do
  @moduledoc(false)
  (
    @callback(fit(model :: String.t(), x :: String.t(), y :: String.t()) :: String.t())
    @callback(predict(model :: String.t(), weights :: String.t(), vector :: [Thrift.i32()]) :: [Thrift.double()])
  )
end