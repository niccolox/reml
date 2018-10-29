defmodule Reml.Env.Utils.ImageTest do
  use ExUnit.Case
  alias Reml.Env.Utils.Image

  @sample_img "test/assets/hw_digits/1.png"

  describe "img_to_vector" do
    vector = Image.to_vector(@sample_img)
    zeroes = Enum.count(vector, &(&1 == 0))
    ones = Enum.count(vector, &(&1 == 1))
    assert zeroes > 0
    assert ones > 0
    assert zeroes + ones == 784
  end
end
