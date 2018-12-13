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

  def application do
    [
      mod: {Reml.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:abci, github: "neocortexlab/abci-ex"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4.0"},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:ethereumex, "~> 0.5.1"},
      {:exleveldb, "~> 0.14"},
      {:export, "~> 0.1.0"},
      {:gen_stage, "~> 0.14.1"},
      {:hackney, "~> 1.12"},
      {:ipfs_api_ex, github: "neocortexlab/ipfs-api-ex"},
      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:merkle_patricia_tree, "~> 0.2.7"},
      {:pallium_core, "~> 0.2.1", github: "neocortexlab/pallium-core"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:sage, "~> 0.4.0"},
      {:temp, "~> 0.4"},
      {:thrift, github: "pinterest/elixir-thrift"},
      {:xandra, "~> 0.10" },
    ]
  end
end
