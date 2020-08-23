defmodule VSCodeExUnitFormatter.ModuleHelpers do
  def to_elixir_module(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
    |> String.to_atom()
  end

  def to_elixir_module(name), do: name
end
