defmodule ExTimezoneDb.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_timezone_db,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 0.10.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:httpoison, "~> 1.1.0"},
      {:poison, "~> 4.0.0"}
    ]
  end
end
