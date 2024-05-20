defmodule Constants do
  def gravities,
    do: %{
      "earth" => 9.807,
      "moon" => 1.62,
      "mars" => 3.711
    }

  def actions,
    do: %{
      :launch => {0.042, 33},
      :land => {0.033, 42}
    }
end
