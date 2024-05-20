defmodule Startup do
  use Application
  alias FuelCalculator

  def start(_type, _args) do
    children = [ FuelCalculator ]

    opts = [strategy: :one_for_one, name: A.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
