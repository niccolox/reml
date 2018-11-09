defmodule Reml.App.AgentController do
  @moduledoc """
  Documentation for Reml Autonomous Intelligent Agents.
  """
  alias Reml.App.Store
  alias Reml.App.Task.BidStorage
  alias Reml.Env
  alias PalliumCore.Core.{Agent, Bid}

  @doc """
  Creates a new entry in the Store with an agent structure and execute construct
  function in agent code

  ## Arguments
    - agent_rlp: Hex string with RLP encoded agent struct
    - address: Address of agent
  """
  def create(agent, address, params) do
    with :ok = Store.update_agent(address, agent),
         {:ok, _} <- dispatch(address, :construct, params),
         do: {:ok, address}
  end

  def send(address, action, props) do
    dispatch(address, :message, %{action: action, data: props})
  end

  defp dispatch(address, method, data) do
    with agent <- Store.get_agent(address),
         state <- agent.state,
         {:ok, module} <- Env.deploy_agent(address, agent.code) do
           Env.dispatch(module, state, address, method, data)
    end
  end

  def transfer(to, from, value) do
    from_agent = Store.get_agent(from)

    cond do
      from == "0x" ->
        to |> Store.get_agent() |> do_transfer(to, value)

      from_agent == nil ->
        {:reject, "sender account does not exist"}

      from_agent.balance < value ->
        {:reject, "sender account insufficient funds"}

      true ->
        to |> Store.get_agent() |> do_transfer(to, value)
        from_agent |> do_transfer(from, -1 * value)
    end
  end

  defp do_transfer(%Agent{} = agent, address, value) do
    updated_agent = %Agent{agent | balance: agent.balance + value, nonce: agent.nonce + 1}
    Store.update_agent(address, updated_agent)
  end

  def get_balance(address) do
    with {:ok, agent} <- Store.get_agent(address) do
      {:ok, agent.balance}
    end
  end

  def bid(%Bid{} = bid) do
    BidStorage.add_bid(bid)
  end
end
