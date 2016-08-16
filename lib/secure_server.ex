defmodule SecureServer do
  @moduledoc """
  SecureServer provides the encoder and decoder for secure Phoenix web servers.

  While not all the functions defined here are used in Phoenix or Plug, they are
  important to have to implement a 'complete' encoder/decoder.

  The encoding and decoding functions in this file MUST match those in
  `:secure_client`, or else they will not be able to communicate.
  """

  @type encoded      :: binary
  @type safe_encoded :: {:ok, encoded} | {:error, any}
  @type decoded      :: map | struct | list
  @type safe_decoded :: {:ok, decoded} | {:error, any}

  @doc """
  Encodes any valid elixir structure as an encrypted, base64 encoded binary.
  """
  @spec encode(decoded) :: safe_encoded
  def encode(data) do
    with {:ok, json} <- Poison.encode(data),
      do: {:ok, json |> Cloak.encrypt |> :base64.encode}
  end

  @doc """
  Decodes any encrypted, base64 encoded binary into a valid elixir structure.
  """
  @spec decode(encoded) :: safe_decoded
  def decode(data) do
    data
    |> :base64.decode
    |> Cloak.decrypt
    |> Poison.decode
  end

  @doc """
  Calls `encode/1`. Since the data ends up encoded with base64, the iodata is
  the same as the binary.
  """
  @spec encode_to_iodata(decoded) :: safe_encoded
  def encode_to_iodata(data), do: encode(data)

  @doc """
  Encodes any valid elixir structure as an encrypted, base64 encoded binary.
  """
  @spec encode!(decoded) :: encoded
  def encode!(data) do
    data
    |> Poison.encode!
    |> Cloak.encrypt
    |> :base64.encode
  end

  @doc """
  Decodes any encrypted, base64 encoded binary into a valid elixir structure.

  This method is used in Plug.Parsers.ENCRYPTED.
  """
  @spec decode!(encoded) :: decoded
  def decode!(data) do
    data
    |> :base64.decode
    |> Cloak.decrypt
    |> Poison.decode!
  end

  @doc """
  Calls `encode!/1`. Since the data ends up encoded with base64, the iodata is
  the same as the binary.

  This function is called when rendering encrypted data in Phoenix.
  """
  @spec encode_to_iodata!(decoded) :: encoded
  def encode_to_iodata!(data), do: encode!(data)
end
