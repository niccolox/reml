defmodule(ReMLService) do
  @moduledoc(false)
  defmodule(FitArgs) do
    @moduledoc(false)
    _ = "Auto-generated Thrift struct Elixir.FitArgs"
    _ = "1: string model"
    _ = "2: string x"
    _ = "3: string y"
    defstruct(model: nil, x: nil, y: nil)
    @type(t :: %__MODULE__{})
    def(new) do
      %__MODULE__{}
    end
    defmodule(BinaryProtocol) do
      @moduledoc(false)
      def(deserialize(binary)) do
        deserialize(binary, %FitArgs{})
      end
      defp(deserialize(<<0, rest::binary>>, %FitArgs{} = acc)) do
        {acc, rest}
      end
      defp(deserialize(<<11, 1::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | model: value})
      end
      defp(deserialize(<<11, 2::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | x: value})
      end
      defp(deserialize(<<11, 3::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | y: value})
      end
      defp(deserialize(<<field_type, _id::16-signed, rest::binary>>, acc)) do
        rest |> Thrift.Protocol.Binary.skip_field(field_type) |> deserialize(acc)
      end
      defp(deserialize(_, _)) do
        :error
      end
      def(serialize(%FitArgs{model: model, x: x, y: y})) do
        [case(model) do
          nil ->
            <<>>
          _ ->
            [<<11, 1::16-signed, byte_size(model)::32-signed>> | model]
        end, case(x) do
          nil ->
            <<>>
          _ ->
            [<<11, 2::16-signed, byte_size(x)::32-signed>> | x]
        end, case(y) do
          nil ->
            <<>>
          _ ->
            [<<11, 3::16-signed, byte_size(y)::32-signed>> | y]
        end | <<0>>]
      end
    end
    def(serialize(struct)) do
      BinaryProtocol.serialize(struct)
    end
    def(serialize(struct, :binary)) do
      BinaryProtocol.serialize(struct)
    end
    def(deserialize(binary)) do
      BinaryProtocol.deserialize(binary)
    end
  end
  defmodule(PredictArgs) do
    @moduledoc(false)
    _ = "Auto-generated Thrift struct Elixir.PredictArgs"
    _ = "1: string model"
    _ = "2: string weights"
    _ = "3: list<i32> vector"
    defstruct(model: nil, weights: nil, vector: nil)
    @type(t :: %__MODULE__{})
    def(new) do
      %__MODULE__{}
    end
    defmodule(BinaryProtocol) do
      @moduledoc(false)
      def(deserialize(binary)) do
        deserialize(binary, %PredictArgs{})
      end
      defp(deserialize(<<0, rest::binary>>, %PredictArgs{} = acc)) do
        {acc, rest}
      end
      defp(deserialize(<<11, 1::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | model: value})
      end
      defp(deserialize(<<11, 2::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | weights: value})
      end
      defp(deserialize(<<15, 3::16-signed, 8, remaining::32-signed, rest::binary>>, struct)) do
        deserialize__vector(rest, [[], remaining, struct])
      end
      defp(deserialize(<<field_type, _id::16-signed, rest::binary>>, acc)) do
        rest |> Thrift.Protocol.Binary.skip_field(field_type) |> deserialize(acc)
      end
      defp(deserialize(_, _)) do
        :error
      end
      defp(deserialize__vector(<<rest::binary>>, [list, 0, struct])) do
        deserialize(rest, %{struct | vector: Enum.reverse(list)})
      end
      defp(deserialize__vector(<<element::32-signed, rest::binary>>, [list, remaining | stack])) do
        deserialize__vector(rest, [[element | list], remaining - 1 | stack])
      end
      defp(deserialize__vector(_, _)) do
        :error
      end
      def(serialize(%PredictArgs{model: model, weights: weights, vector: vector})) do
        [case(model) do
          nil ->
            <<>>
          _ ->
            [<<11, 1::16-signed, byte_size(model)::32-signed>> | model]
        end, case(weights) do
          nil ->
            <<>>
          _ ->
            [<<11, 2::16-signed, byte_size(weights)::32-signed>> | weights]
        end, case(vector) do
          nil ->
            <<>>
          _ ->
            [<<15, 3::16-signed, 8, length(vector)::32-signed>> | for(e <- vector) do
              <<e::32-signed>>
            end]
        end | <<0>>]
      end
    end
    def(serialize(struct)) do
      BinaryProtocol.serialize(struct)
    end
    def(serialize(struct, :binary)) do
      BinaryProtocol.serialize(struct)
    end
    def(deserialize(binary)) do
      BinaryProtocol.deserialize(binary)
    end
  end
  defmodule(FitResponse) do
    @moduledoc(false)
    _ = "Auto-generated Thrift struct Elixir.FitResponse"
    _ = "0: string success"
    defstruct(success: nil)
    @type(t :: %__MODULE__{})
    def(new) do
      %__MODULE__{}
    end
    defmodule(BinaryProtocol) do
      @moduledoc(false)
      def(deserialize(binary)) do
        deserialize(binary, %FitResponse{})
      end
      defp(deserialize(<<0, rest::binary>>, %FitResponse{} = acc)) do
        {acc, rest}
      end
      defp(deserialize(<<11, 0::16-signed, string_size::32-signed, value::binary-size(string_size), rest::binary>>, acc)) do
        deserialize(rest, %{acc | success: value})
      end
      defp(deserialize(<<field_type, _id::16-signed, rest::binary>>, acc)) do
        rest |> Thrift.Protocol.Binary.skip_field(field_type) |> deserialize(acc)
      end
      defp(deserialize(_, _)) do
        :error
      end
      def(serialize(%FitResponse{success: success})) do
        [case(success) do
          nil ->
            <<>>
          _ ->
            [<<11, 0::16-signed, byte_size(success)::32-signed>> | success]
        end | <<0>>]
      end
    end
    def(serialize(struct)) do
      BinaryProtocol.serialize(struct)
    end
    def(serialize(struct, :binary)) do
      BinaryProtocol.serialize(struct)
    end
    def(deserialize(binary)) do
      BinaryProtocol.deserialize(binary)
    end
  end
  defmodule(PredictResponse) do
    @moduledoc(false)
    _ = "Auto-generated Thrift struct Elixir.PredictResponse"
    _ = "0: list<double> success"
    defstruct(success: nil)
    @type(t :: %__MODULE__{})
    def(new) do
      %__MODULE__{}
    end
    defmodule(BinaryProtocol) do
      @moduledoc(false)
      def(deserialize(binary)) do
        deserialize(binary, %PredictResponse{})
      end
      defp(deserialize(<<0, rest::binary>>, %PredictResponse{} = acc)) do
        {acc, rest}
      end
      defp(deserialize(<<15, 0::16-signed, 4, remaining::32-signed, rest::binary>>, struct)) do
        deserialize__success(rest, [[], remaining, struct])
      end
      defp(deserialize(<<field_type, _id::16-signed, rest::binary>>, acc)) do
        rest |> Thrift.Protocol.Binary.skip_field(field_type) |> deserialize(acc)
      end
      defp(deserialize(_, _)) do
        :error
      end
      defp(deserialize__success(<<rest::binary>>, [list, 0, struct])) do
        deserialize(rest, %{struct | success: Enum.reverse(list)})
      end
      defp(deserialize__success(<<0::1, 2047::11, 0::52, rest::binary>>, [list, remaining | stack])) do
        deserialize__success(rest, [[:inf | list], remaining - 1 | stack])
      end
      defp(deserialize__success(<<1::1, 2047::11, 0::52, rest::binary>>, [list, remaining | stack])) do
        deserialize__success(rest, [[:"-inf" | list], remaining - 1 | stack])
      end
      defp(deserialize__success(<<sign::1, 2047::11, frac::52, rest::binary>>, [list, remaining | stack])) do
        deserialize__success(rest, [[%Thrift.NaN{sign: sign, fraction: frac} | list], remaining - 1 | stack])
      end
      defp(deserialize__success(<<element::signed-float, rest::binary>>, [list, remaining | stack])) do
        deserialize__success(rest, [[element | list], remaining - 1 | stack])
      end
      defp(deserialize__success(_, _)) do
        :error
      end
      def(serialize(%PredictResponse{success: success})) do
        [case(success) do
          nil ->
            <<>>
          _ ->
            [<<15, 0::16-signed, 4, length(success)::32-signed>> | for(e <- success) do
              case(e) do
                :inf ->
                  <<0::1, 2047::11, 0::52>>
                :"-inf" ->
                  <<1::1, 2047::11, 0::52>>
                %Thrift.NaN{sign: sign, fraction: frac} ->
                  <<sign::1, 2047::11, frac::52>>
                _ ->
                  <<e::float-signed>>
              end
            end]
        end | <<0>>]
      end
    end
    def(serialize(struct)) do
      BinaryProtocol.serialize(struct)
    end
    def(serialize(struct, :binary)) do
      BinaryProtocol.serialize(struct)
    end
    def(deserialize(binary)) do
      BinaryProtocol.deserialize(binary)
    end
  end
  defmodule(Binary.Framed.Client) do
    @moduledoc(false)
    alias(Thrift.Binary.Framed.Client, as: ClientImpl)
    defdelegate(close(conn), to: ClientImpl)
    defdelegate(connect(conn, opts), to: ClientImpl)
    defdelegate(start_link(host, port, opts \\ []), to: ClientImpl)
    def(unquote(:fit)(client, model, x, y, rpc_opts \\ [])) do
      args = %FitArgs{model: model, x: x, y: y}
      serialized_args = FitArgs.BinaryProtocol.serialize(args)
      ClientImpl.call(client, "fit", serialized_args, FitResponse.BinaryProtocol, rpc_opts)
    end
    def(unquote(:fit!)(client, model, x, y, rpc_opts \\ [])) do
      case(unquote(:fit)(client, model, x, y, rpc_opts)) do
        {:ok, rsp} ->
          rsp
        {:error, {:exception, ex}} ->
          raise(ex)
        {:error, reason} ->
          raise(Thrift.ConnectionError, reason: reason)
      end
    end
    def(unquote(:predict)(client, model, weights, vector, rpc_opts \\ [])) do
      args = %PredictArgs{model: model, weights: weights, vector: vector}
      serialized_args = PredictArgs.BinaryProtocol.serialize(args)
      ClientImpl.call(client, "predict", serialized_args, PredictResponse.BinaryProtocol, rpc_opts)
    end
    def(unquote(:predict!)(client, model, weights, vector, rpc_opts \\ [])) do
      case(unquote(:predict)(client, model, weights, vector, rpc_opts)) do
        {:ok, rsp} ->
          rsp
        {:error, {:exception, ex}} ->
          raise(ex)
        {:error, reason} ->
          raise(Thrift.ConnectionError, reason: reason)
      end
    end
  end
  defmodule(Binary.Framed.Server) do
    @moduledoc(false)
    require(Logger)
    alias(Thrift.Binary.Framed.Server, as: ServerImpl)
    defdelegate(stop(name), to: ServerImpl)
    def(start_link(handler_module, port, opts \\ [])) do
      ServerImpl.start_link(__MODULE__, port, handler_module, opts)
    end
    def(handle_thrift("fit", binary_data, handler_module)) do
      case(Elixir.ReMLService.FitArgs.BinaryProtocol.deserialize(binary_data)) do
        {%ReMLService.FitArgs{model: model, x: x, y: y}, ""} ->
          try() do
            rsp = handler_module.fit(model, x, y)
            (
              response = %ReMLService.FitResponse{success: rsp}
              {:reply, Elixir.ReMLService.FitResponse.BinaryProtocol.serialize(response)}
            )
          rescue
            []
          catch
            kind, reason ->
              formatted_exception = Exception.format(kind, reason, System.stacktrace())
              Logger.error("Exception not defined in thrift spec was thrown: #{formatted_exception}")
              error = Thrift.TApplicationException.exception(type: :internal_error, message: "Server error: #{formatted_exception}")
              {:server_error, error}
          end
        {_, extra} ->
          raise(Thrift.TApplicationException, type: :protocol_error, message: "Could not decode #{inspect(extra)}")
      end
    end
    def(handle_thrift("predict", binary_data, handler_module)) do
      case(Elixir.ReMLService.PredictArgs.BinaryProtocol.deserialize(binary_data)) do
        {%ReMLService.PredictArgs{model: model, weights: weights, vector: vector}, ""} ->
          try() do
            rsp = handler_module.predict(model, weights, vector)
            (
              response = %ReMLService.PredictResponse{success: rsp}
              {:reply, Elixir.ReMLService.PredictResponse.BinaryProtocol.serialize(response)}
            )
          rescue
            []
          catch
            kind, reason ->
              formatted_exception = Exception.format(kind, reason, System.stacktrace())
              Logger.error("Exception not defined in thrift spec was thrown: #{formatted_exception}")
              error = Thrift.TApplicationException.exception(type: :internal_error, message: "Server error: #{formatted_exception}")
              {:server_error, error}
          end
        {_, extra} ->
          raise(Thrift.TApplicationException, type: :protocol_error, message: "Could not decode #{inspect(extra)}")
      end
    end
  end
end