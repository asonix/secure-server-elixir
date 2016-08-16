# SecureServer

A plugin for Phoenix and Plug to allow for more secure interaction with clients,
and companion project to
[SecureClient](https://github.com/asonix/secure-client-elixir).

## Installation

Add `secure_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:secure_server, "~> 0.1.0"}]
end
```

## Configuration

In your config/config.exs, setup the MIME type(s), FormatEncoder(s),
and Encryption method(s)
```elixir
# config/config.exs

config :mime, :types, %{
  "application/encrypted" => ["encrypted"]
}

config :phoenix, :format_encoders,
  encrypted: SecureServer

config :cloak, Cloak.AES.CTR,
  # Note, this config must be identical to the one used in your client
  # See https://github.com/danielberkompas/cloak for more details encryption
  tag: "AES",
  default: true,
  keys: [
    %{
      tag: <<1>>,
      key: :base64.decode(System.get_env("YOUR_SYMMETRIC_KEY")),
      default: true
    }
  ]

```
See [Cloak](https://github.com/danielberkompas/cloak) for more info about
encryption.

In your endpoint file, include `:encrypted` in the valid parsers, and set the
encrypted parser to `SecureServer`.
```elixir
# lib/your_application/endpoint.ex

plug Plug.Parsers,
    parsers: [:encrypted, :urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    encrypted_decoder: SecureServer
```

In the router, add `encrypted` to your accepts, either in it's own pipeline
(more secure) or in an existing pipeline.
```elixir
# web/router

pipeline :secure do
  accepts, ["encrypted"]
  ...
end
```

In the error view, add or change the error render functions to use `encrypted`
in addition to or instead of `html` or `json`.
```elixir
# web/views/error_view.ex

defmodule YourApplication.ErrorView do
  use YourApplication.Web, :view

  ...

  def render("404.encrypted", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  ...

  def render("500.encrypted", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  ...

end
```

## Usage

When rendering, render using the `.encrypted` renderers rather than the `.json`
or `.html` renderers.

## Secure Client

See [SecureClient](https://github.com/asonix/secure-client-elixir) for detalis
on created an elixir client to interact with this server.

## License

```
Copyright © 2016 Riley Trautman, <asonix.dev@gmail.com>

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.
```
