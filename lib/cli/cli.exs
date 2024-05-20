defmodule Cli.Cli do
  alias FuelCalculator
  alias CLI.Helpers

  [equipment_mass_string, flight_path_string] =
    System.argv()
    |> Enum.at(0)
    |> String.replace(" ", "")
    |> String.split(",[")

  equipment_mass = String.to_integer(equipment_mass_string)
  flight_path = Helpers.parse_atom_string_tuple_list(flight_path_string)

  IO.puts GenServer.call(FuelCalculator, {:calculate, {equipment_mass, flight_path}})
end
