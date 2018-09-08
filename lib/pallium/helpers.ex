defmodule Helpers do
  @moduledoc """
  Helpers for common operations
  """

  def keccak(data), do: :keccakf1600.sha3_256(data)

  def pid_to_binary(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> :erlang.list_to_binary()
  end

  def pid_from_string(string) do
    string
    |> :erlang.binary_to_list()
    |> :erlang.list_to_pid()
  end

  def observer do
    ob = fn f ->
      receive do
        {_, msg} ->
          IO.puts(msg)
          f.(f)
      end
    end

    spawn(fn -> ob.(ob) end)
  end
end
