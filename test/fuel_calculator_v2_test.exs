defmodule FuelCalculatorV2Test do
  use ExUnit.Case
  doctest FuelCalculatorV2

  setup do
    {:ok, pid} = GenServer.start_link(FuelCalculatorV2, {})
    {:ok, pid: pid}
  end

  test "Test fuel calculation", context do
    tests = [
      {51898,
       {28801, [{:launch, "earth"}, {:land, "moon"}, {:launch, "moon"}, {:land, "earth"}]}},
      {33388,
       {14606, [{:launch, "earth"}, {:land, "mars"}, {:launch, "mars"}, {:land, "earth"}]}},
      {212_161,
       {75432,
        [
          {:launch, "earth"},
          {:land, "moon"},
          {:launch, "moon"},
          {:land, "mars"},
          {:launch, "mars"},
          {:land, "earth"}
        ]}}
    ]

    Enum.each(tests, fn {expected, {equipment_mass, flight_path}} ->
      assert GenServer.call(context[:pid], {:calculate, {equipment_mass, flight_path}}) ==
               expected
    end)
  end

  test "Test invalid planet", context do
    assert GenServer.call(
             context[:pid],
             {:calculate,
              {28801,
               [{:launch, "earth"}, {:land, "moon"}, {:launch, "moon"}, {:land, "jupiter"}]}}
           ) ==
             {:error, "Invalid flight path or unkown gravity."}
  end

  test "Test invalid action", context do
    assert GenServer.call(
             context[:pid],
             {:calculate,
              {28801,
               [
                 {:jump, "earth"},
                 {:land, "moon"},
                 {:launch, "moon"},
                 {:land, "earth"},
                 {:land, "earth"}
               ]}}
           ) ==
             {:error, "Invalid flight path or unkown gravity."}
  end

  test "Test invalid action sequence", context do
    assert GenServer.call(
             context[:pid],
             {:calculate,
              {28801,
               [
                 {:launch, "earth"},
                 {:land, "moon"},
                 {:launch, "moon"},
                 {:land, "earth"},
                 {:land, "earth"}
               ]}}
           ) ==
             {:error, "Invalid flight path or unkown gravity."}
  end

  test "Test invalid planet-action sequence", context do
    assert GenServer.call(
             context[:pid],
             {:calculate,
              {28801,
               [
                 {:launch, "earth"},
                 {:land, "moon"},
                 {:launch, "earth"},
                 {:land, "earth"},
                 {:launch, "earth"}
               ]}}
           ) ==
             {:error, "Invalid flight path or unkown gravity."}
  end
end
