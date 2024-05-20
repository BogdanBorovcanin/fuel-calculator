defmodule FuelCalculator do
  use GenServer, restart: :transient
  alias Constants

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  def handle_call({:calculate, {equipment_mass, _flight_path}}, _from, state)
      when not is_number(equipment_mass) do
    {:reply, {:error, "Invalid equipment mass"}, state}
  end

  @impl true
  def handle_call({:calculate, {_, flight_path}}, _from, state) when not is_list(flight_path) do
    {:reply, {:error, "Invalid flight path"}, state}
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

  defp calculate_fuel(mass, {action, planet}) do
    {coefficient, down_mass} = Constants.actions()[action]

    fuel =
      (mass * Constants.gravities()[planet] * coefficient - down_mass)
      |> floor()
      |> Kernel.max(0)

    fuel + calculate_fuel(fuel, {action, planet})
  end

  defp calculate_flight_path_fuel(mass, []), do: mass

  defp calculate_flight_path_fuel(mass, [operation | tail]) do
    tail_mass = calculate_flight_path_fuel(mass, tail)
    operation_fuel_mass = calculate_fuel(tail_mass, operation)

    tail_mass + operation_fuel_mass
  end
end
