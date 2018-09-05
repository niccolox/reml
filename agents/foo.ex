agent "{{address}}" do
  def construct(_params) do
    %{foo: "bar", hello: "Hello, world!"}
    |> set_state()
  end

  def handle(action, _data) do
    case action do
      "foo" -> get_value("foo")
      "hello" -> get_value("hello") |> Env.in_chan(@self)
    end
  end
end
