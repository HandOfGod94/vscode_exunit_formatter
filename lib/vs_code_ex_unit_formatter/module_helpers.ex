defmodule VSCodeExUnitFormatter.ModuleHelpers do
  def to_elixir_module(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
    |> String.to_atom()
  end

  def to_elixir_module(name), do: name

  def module_id(module_name) when is_atom(module_name) do
    module_name
    |> to_elixir_module()
    |> Atom.to_string()
    |> Recase.to_kebab()
  end

  def module_id(module_name), do: module_name
end
