defmodule TxValidatorTest do
  use ExUnit.Case

  alias Pallium.Core.TxValidator
  alias Pallium.Core.Transaction, as: Tx

  describe ":send" do
    test "requires recepient" do
      address = AgentHelpers.random_address()
      data = ""
      tx =
        {0, :send, address, nil, 0, data}
        |> Tx.build()
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
        {0, :bid, nil, address, 0, data}
        |> Tx.build()
      assert {:agent_missing, address} == TxValidator.validate(tx)

      AgentHelpers.create("foo", address)

      assert :ok == TxValidator.validate(tx)
    end
  end
end
