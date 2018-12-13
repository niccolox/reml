defmodule Reml.Tendermint.Response do
  @moduledoc """
  Adapter for building ABCI responses
  """

  @check_tx_codes %{
    ok: 0,
    agent_not_found: 1,
    bid_not_found: 2,
  }

  @deliver_tx_codes %{
    ok: 0,
    encoding_error: 1,
    bad_nonce: 2,
    unauthorized: 3,
  }

  def build(type, params) do
    type
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
    |> String.replace_prefix("", "Elixir.ABCI.Types.Response")
    |> String.to_atom()
    |> Kernel.apply(:new, build_params(type, params))
  end

  defp build_params(:deliver_tx, :ok), do: [[code: @deliver_tx_codes.ok]]

  defp build_params(:deliver_tx, {:ok, result}) do
    [[
      code: @deliver_tx_codes.ok,
      data: result |> to_string()
    ]]
  end

  defp build_params(:deliver_tx, {:error, _reason}) do
    [[code: @deliver_tx_codes.encoding_error]]
  end

  defp build_params(:check_tx, :ok), do: [[code: @check_tx_codes.ok]]

  defp build_params(:check_tx, {:error, {type, info}}) do
    [[
      code: @check_tx_codes[type],
      info: info
    ]]
  end

  defp build_params(type, :ok) when type in ~w(begin_block end_block)a, do: [[code: 0]]

  defp build_params(type, :ok) when type in ~w(init_chain)a, do: []

  defp build_params(type, params) when type in ~w(info commit)a, do: [params]
end
