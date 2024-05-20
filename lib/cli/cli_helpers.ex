defmodule CLI.Helpers do
  def parse_atom_string_tuple_list(tuple_list_string) do
    tuple_list_string
    |> String.trim("[")
    |> String.trim("]")
    |> String.split("},{")
    |> Enum.map(&parse_atom_string_tuple(&1))
  end

  def parse_atom_string_tuple(tuple_string) do
    tuple_string = tuple_string |> String.trim("{") |> String.trim("}")
    [atom_string, string] = String.split(tuple_string, ",")

    atom =
      atom_string
      |> String.trim(":")
      |> String.to_atom()

    {atom, String.trim(string, "\"")}
  end
end
