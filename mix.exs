defmodule FuelCalculator.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuel_calculator,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Startup, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
