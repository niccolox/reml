defmodule Pallium.Env.Channel do
  defstruct owner: <<>>,
            subscribers: <<>>,
            events: <<>>

  def open() do
    spawn(__MODULE__, :new, [])
  end

  def init() do
    "init"
  end

  def close() do
    "close"
  end

  def set_state(next_state) do
    "new state"
  end

  def new() do
    receive do
      {_, message} -> IO.puts(message)
      {:register, address} -> IO.puts(address)
    end
    new()
  end

  def commit() do
    "state"
  end

  def subscribe() do
    "subscriber"
  end
end
