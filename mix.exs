defmodule Reml.MixProject do
  use Mix.Project

  def project do
    [
      app: :reml,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "Open source decentralized ecosystem for autonomous intelligent agents",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: [
          "Anton Zhuravlev <anton@pallium.network>",
          "Dmitry Zhelnin <dmitry.zhelnin@gmail.com>",
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/neocortexlab/reml"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Reml.Application, []},
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
      {:exleveldb, "~> 0.14"},
      {:hackney, "~> 1.12"},

      # jsonrpc2 requires sending request id as a string, which is implemented in this fork
      {:jsonrpc2, github: "whitered/jsonrpc2-elixir"},

      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:merkle_patricia_tree, "~> 0.2.7"},
      {:pallium_core, github: "neocortexlab/pallium-core"},
      {:poison, "~> 3.1"},
      {:export, "~> 0.1.0"},
      {:ipfs_api_ex, github: "neocortexlab/ipfs-api-ex"},
      {:xandra, "~> 0.10" },
      {:thrift, github: "pinterest/elixir-thrift"},

      # temporary fix :ranch version until cowboy upgrade to ranch >= 1.6 which is required by thrift
      # TODO: remove :ranch dep later!
      {:ranch, "~> 1.6", override: true},

      {:sage, "~> 0.4.0"},
      {:temp, "~> 0.4"},
    ]
  end
end
