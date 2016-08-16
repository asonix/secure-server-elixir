defmodule Plug.Parsers.ENCRYPTED do
  @moduledoc """
  Parses ENCRYPTED request body.

  ENCRYPTED arrays are parsed into a `"_encrypted"` key to allow
  proper param merging.

  An empty request body is parsed as an empty map.

  Blatently ripped from
  https://github.com/elixir-lang/plug/blob/master/lib/plug/parsers/json.ex
  """

  @behaviour Plug.Parsers
  import Plug.Conn

  def parse(conn, "application", subtype, _headers, opts) do
    if subtype == "encrypted" || String.ends_with?(subtype, "+encrypted") do
      decoder = Keyword.get(opts, :encrypted_decoder) ||
                  raise ArgumentError, "ENCRYPTED parser expects a :encrypted_decoder option"
      conn
      |> read_body(opts)
      |> decode(decoder)
    else
      {:next, conn}
    end
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:more, _, conn}, _decoder) do
    {:error, :too_large, conn}
  end

  defp decode({:ok, "", conn}, _decoder) do
    {:ok, %{}, conn}
  end

  defp decode({:ok, body, conn}, decoder) do
    case decoder.decode!(body) do
      terms when is_map(terms) ->
        {:ok, terms, conn}
      terms ->
        {:ok, %{"_encrypted" => terms}, conn}
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end
end
