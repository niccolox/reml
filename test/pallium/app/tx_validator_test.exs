defmodule Pallium.App.TxValidatorTest do
  use ExUnit.Case

  alias Pallium.App.TxValidator
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

      assert {:agent_missing, address} == TxValidator.validate(tx)

      AgentHelpers.create("foo", address)

      assert :ok == TxValidator.validate(tx)
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
      assert {:agent_missing, address} == TxValidator.validate(tx)

      AgentHelpers.create("foo", address)

      assert :ok == TxValidator.validate(tx)
    end
  end
end
