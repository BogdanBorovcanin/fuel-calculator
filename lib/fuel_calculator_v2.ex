defmodule FuelCalculatorV2 do
  use GenServer
  alias Constants

  # This FuelCalculatorV2 module is a refactored version of the FuelCalculator module to use pattern matching and recursion to calculate the fuel needed for a flight path.
  # This is just to showcase pattern matching, though I prefer the original version for maintainability, due to constants being defined in the Constants module and expandabile with new actions and planets.
  # Also, V1 is much more readable and easier to understand.

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  def handle_call({:calculate, {equipment_mass, flight_path}}, _from, state) do
    with true <- verify_flight_path_type(flight_path),
         true <- verify_flight_path(flight_path),
         true <- verify_flight_sequence(flight_path),
         total_flight_fuel <- calculate_flight_path_fuel(equipment_mass, flight_path) do
      {:reply, total_flight_fuel - equipment_mass, state}
    else
      _ -> {:reply, {:error, "Invalid flight path or unkown gravity."}, state}
    end
  end

  defp verify_flight_path_type(flight_path),
    do:
      Enum.all?(flight_path, fn tuple ->
        is_atom(elem(tuple, 0)) and is_binary(elem(tuple, 1))
      end)

  defp verify_flight_path(flight_path),
    do:
      Enum.all?(flight_path, fn {action, planet} ->
        action in Map.keys(Constants.actions()) and planet in Map.keys(Constants.gravities())
      end)

  defp verify_flight_sequence(flight_path) do
    {result, _, _} =
      Enum.reduce(flight_path, {true, nil, nil}, fn {action, planet},
                                                    {result, prev_action, prev_planet} ->
        if prev_action == action or (prev_action == :land and planet != prev_planet) do
          {false, action, planet}
        else
          {result, action, planet}
        end
      end)

    result
  end

  defp calculate_fuel(0, _), do: 0

  defp calculate_fuel(mass, {:land, planet}) do
    fuel =
      (mass * Constants.gravities()[planet] * 0.033 - 42)
      |> floor()
      |> Kernel.max(0)

    fuel + calculate_fuel(fuel, {:land, planet})
  end

  defp calculate_fuel(mass, {:launch, planet}) do
    fuel =
      (mass * Constants.gravities()[planet] * 0.042 - 33)
      |> floor()
      |> Kernel.max(0)

    fuel + calculate_fuel(fuel, {:launch, planet})
  end

  defp calculate_flight_path_fuel(mass, []), do: mass

  #  Less readable version, IF you want to use the pipe operator
  defp calculate_flight_path_fuel(mass, [{action, planet} | tail]),
    do:
      calculate_flight_path_fuel(mass, tail)
      |> (&(&1 + calculate_fuel(&1, {action, planet}))).()
end
