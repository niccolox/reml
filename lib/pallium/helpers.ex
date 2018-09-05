defmodule Helpers do
  @moduledoc """
  Helpers for common operations
  """

  @type keccak_hash :: binary()

  @spec keccak(binary()) :: keccak_hash
  def keccak(data), do: :keccakf1600.sha3_256(data)

  @spec from_hex(String.t()) :: binary()
  def from_hex(hex_data), do: Base.decode16!(hex_data, case: :lower)

  @spec to_hex(binary()) :: String.t()
  def to_hex(bin), do: Base.encode16(bin, case: :lower)

  def pid_to_binary(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> :erlang.list_to_binary()
  end

  def pid_from_string(string) do
    string
    |> :erlang.binary_to_list()
    |> :erlang.list_to_pid()
  end

  def decode_map(string) do
    string
    |> String.split(",")
    |> Enum.reject(&(&1 == ""))
    |> Map.new(
      fn pair_str ->
        [k, v] =
          pair_str
          |> String.split("=")
          |> Enum.map(&from_hex/1)
        {String.to_atom(k), v}
      end
    )
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
