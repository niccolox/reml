defmodule Pallium.Env.Channel do
  @moduledoc """
  Documentation for Pallium Channel.
  """

  defstruct parties: [],
            owner: <<>>,
            observers: []

  @type t :: %__MODULE__{
          parties: [Pallium.Myelin.Address.address()],
          owner: Pallium.Myelin.Address.address(),
          observers: [pid()]
        }

  @spec open(Pallium.Myelin.Address.address()) :: pid()
  def open(owner) do
    state = %__MODULE__{%__MODULE__{} | owner: owner, parties: [owner]}
    spawn(__MODULE__, :new, [state])
  end

  def new(state) do
    receive do
      {:ok, msg} -> broadcast(msg, state.observers)
      {:connect, pid} -> new(%{state | observers: state.observers ++ [pid]})
      :state -> IO.puts("#{inspect state}")
    end
    new(state)
  end

  def broadcast(msg, observers) do
    Enum.each(observers, fn(p) -> send p, {:ok, msg} end)
  end

  def commit() do
    "state"
  end
end
