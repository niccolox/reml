agent "{{address}}" do
  def construct do
    %{a: "1", b: "2"}
    |> set_state()
  end

  def handle("set", data) do
    [key, value] = String.split(data, "=")
    set_value(key, value)
  end

  def handle("get", key) do
    get_value(key)
  end

  def handle("set_and_fail", data) do
    [key, value] = String.split(data, "=")
    set_value(key, value)
    raise "boom"
  end
end
