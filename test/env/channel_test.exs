defmodule ChannelTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Pallium.Myelin.Store
  alias Pallium.Env.Channel
  alias Pallium.Myelin.Agent
  alias Pallium.Myelin.Message
  alias Pallium.Env

  doctest Channel

  @agent "eeb2be97535a4444950ce7304fc93ad0a216051244dda3021799dbe92edb0f19"

  test "should broadcast msg to observer" do
    observer = Helpers.observer()
    chan = Channel.open(@agent)
    send(chan, {:connect, observer})

    output =
      capture_io(fn ->
        Process.group_leader(observer, self())
        send(chan, {:ok, "hello"})
      end)

    assert_receive {:io_request, _, _, {:put_chars, :unicode, "hello\n"}}

    Process.exit(observer, :kill)
    Process.exit(chan, :kill)
  end
end
