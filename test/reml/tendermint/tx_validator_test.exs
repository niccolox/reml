defmodule Reml.Tendermint.TxValidatorTest do
  use ExUnit.Case

  alias Reml.Tendermint.TxValidator
  alias PalliumCore.Core.Transaction, as: Tx

  describe ":send" do
    test "requires recepient" do
      address = AgentHelpers.random_address()
      data = ""
      tx =
        %Tx{
          type: :send,
          to: address,
          data: data
        }

      assert {:error, {:agent_not_found, _}} = TxValidator.validate_tx(tx)

      AgentHelpers.create("foo", address)

      assert :ok == TxValidator.validate_tx(tx)
    end
  end

  describe ":bid" do
    test "requires sender" do
      address = AgentHelpers.random_address()
      data = ""
      tx =
        %Tx{
          type: :bid,
          from: address,
          data: data
        }
      assert {:error, {:agent_not_found, _}} = TxValidator.validate_tx(tx)

      AgentHelpers.create("foo", address)

      assert :ok == TxValidator.validate_tx(tx)
    end
  end
end
