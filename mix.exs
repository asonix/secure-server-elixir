defmodule SecureServer.Mixfile do
  use Mix.Project

  def project do
    [app: :secure_server,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: []]
  end

  def description do
    """
    A plugin for Phoenix and Plug to allow for more secure interaction with
    clients.
    """
  end

  def package do
    [name: :secure_server,
     maintainers: ["Riley Trautman", "asonix.dev@gmail.com"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/asonix/secure-server-elixir"}]
  end

  defp deps do
    [{:poison, "~> 2.2"},
     {:cloak, "~> 0.2"},
     {:plug, "~> 1.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:bypass, "~> 0.1", only: :test},
     {:http_client, "~> 0.1", only: :test},
     {:secure_client, "~> 0.1", only: :test}]
  end
end
