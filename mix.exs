defmodule Pallium.MixProject do
  use Mix.Project

  def project do
    [
      app: :pallium,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: "Open source decentralized ecosystem for autonomous intelligent agents",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: ["Anton Zhuravlev <anton@pallium.network>"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/neocortexlab/pallium"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:sage, "~> 0.4.0"},
      {:ed25519, "~> 1.3"},
      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:ex_rlp, "~> 0.3.0"},
      {:merkle_patricia_tree, "~> 0.2.7"},
      {:exleveldb, "~> 0.13.1"},
      {:abci, path: "/Users/xcilog/Documents/projects/pallium/abci-ex"},
      {:jsonrpc2, "~> 1.0"},
      {:hackney, "~> 1.12"}
    ]
  end
end
