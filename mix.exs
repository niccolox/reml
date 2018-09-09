defmodule Pallium.MixProject do
  use Mix.Project

  def project do
    [
      app: :pallium,
      version: "0.1.0",
      elixir: "~> 1.7",
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
      mod: {Pallium.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:abci, github: "neocortexlab/abci-ex"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4.0"},
      {:cowboy, "~> 2.4"},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:ed25519, "~> 1.3"},
      {:ex_rlp, "~> 0.3.0"},
      {:exleveldb, "~> 0.13.1"},
      {:extensor, "~> 0.1"},
      {:hackney, "~> 1.12"},
      {:jsonrpc2, "~> 1.0.3"},
      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:matrex, "~> 0.6"},
      {:merkle_patricia_tree, "~> 0.2.7"},
      {:pallium_core, github: "neocortexlab/pallium-core"},
      {:poison, "~> 3.1"},

      # temporary fix :ranch version until cowboy upgrade to ranch >= 1.6 which is required by thrift
      # TODO: remove :ranch dep later!
      {:ranch, "~> 1.6", override: true},

      {:sage, "~> 0.4.0"},
    ]
  end
end
