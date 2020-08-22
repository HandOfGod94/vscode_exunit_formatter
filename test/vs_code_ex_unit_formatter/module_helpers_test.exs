defmodule VSCodeExUnitFormatter.ModuleHelpersTest do
  use ExUnit.Case, async: true

  import VSCodeExUnitFormatter.ModuleHelpers

  test "to_elixir_module/1 - strips Elixir prefix from module string" do
    assert to_elixir_module(:"Elixir.Foo.Bar") == :"Foo.Bar"
    assert to_elixir_module(:"Foo.Bar") == :"Foo.Bar"
    assert to_elixir_module("foo") == "foo"
  end

  test "module_id/1 - returns snake case from module name" do
    assert module_id(:"Elixir.Foo.Bar") == "foo-bar"
    assert module_id(:"Foo.Bar") == "foo-bar"
    assert module_id("foo") == "foo"
  end
end
