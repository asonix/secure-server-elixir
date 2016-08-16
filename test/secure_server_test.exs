defmodule SecureServerTest do
  use ExUnit.Case
  doctest SecureServer

  import Client

  @generic_payload %{
    "key" => "value",
    "key2" => [
      "value1",
      "value2",
      "value3"
    ]
  }

  def prepare_conn(conn) do
    parsers_opts = Plug.Parsers.init(parsers: [:encrypted],
                                     pass: ["application/encrypted"],
                                     encrypted_decoder: SecureServer)

    conn
    |> Plug.Parsers.call(parsers_opts)
    |> Plug.Conn.fetch_query_params
    |> Plug.Conn.resp(200, SecureServer.encode!(@generic_payload))
  end

  def assert_request(conn, path, method, params, headers) do
    conn = prepare_conn(conn)

    assert conn.request_path == path
    assert conn.method == method

    if !is_nil(params), do: assert conn.params == params

    Enum.each(headers, fn header ->
      assert header in conn.req_headers
    end)

    conn
  end

  setup do
    bypass = Bypass.open
    url = "localhost:#{bypass.port}/"
    {:ok, bypass: bypass, url: url}
  end

  test "Encrypted.encode encodes data" do
    with {:ok, encoded} <- SecureServer.encode(@generic_payload),
      do: assert is_binary(encoded)
  end

  test "Encrypted.decode decodes encoded data" do
    with {:ok, encoded} <- SecureServer.encode(@generic_payload),
      do: with {:ok, decoded} <- SecureServer.decode(encoded),
        do: assert @generic_payload == decoded
  end

  test "Encrypted.encode! encodes data" do
    assert is_binary(SecureServer.encode!(@generic_payload))
  end

  test "Encrypted.decode! decodes encoded data" do
    decoded = @generic_payload
      |> SecureServer.encode!
      |> SecureServer.decode!

    assert decoded == @generic_payload
  end

  test "urlencoded get with encrypted response", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "GET",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.GETURLEncoded,
      Client.Decoders.Encrypted,
      &Client.get!(&1, &2, &3)
    )
  end

  test "encrypted post", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "POST",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.Encrypted,
      Client.Decoders.Encrypted,
      &Client.post!(&1, &2, &3)
    )
  end

  test "encrypted patch", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "PATCH",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert {:ok, @generic_payload} == do_request(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.Encrypted,
      Client.Decoders.Encrypted,
      &Client.patch(&1, &2, &3)
    )
  end

  test "encrypted put", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "PUT",
        @generic_payload,
        [{"header", "header"}]
      )
    end

    assert {:ok, @generic_payload} == do_request(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.Encrypted,
      Client.Decoders.Encrypted,
      &Client.put(&1, &2, &3)
    )
  end

  test "encrypted delete", %{bypass: bypass, url: url} do
    Bypass.expect bypass, fn conn ->
      assert_request(
        conn,
        "/test",
        "DELETE",
        nil,
        [{"header", "header"}]
      )
    end

    assert @generic_payload == do_request!(
      "#{url}test",
      @generic_payload,
      %{"header" => "header"},
      Client.Encoders.NilEncoder,
      Client.Decoders.Encrypted,
      &Client.delete!(&1, &2, &3)
    )
  end
end
