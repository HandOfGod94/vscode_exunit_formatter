defmodule VSCodeExUnitFormatter.VsSuite do
  import VSCodeExUnitFormatter.ModuleHelpers
  alias VSCodeExUnitFormatter.VsTestCase

  @derive Jason.Encoder
  defstruct [:id, :label, type: "suite", children: [], file: "", errored: false]

  def populate_suite(%ExUnit.TestModule{} = test_module) do
    vscode_tests =
      test_module.tests
      |> Enum.map(&VsTestCase.populate_test/1)
      |> Enum.into([])

    file =
      if vscode_tests != [] do
        vscode_tests |> Enum.at(0) |> Map.get(:file)
      else
        ""
      end

    %__MODULE__{
      type: "suite",
      id: test_module.name,
      label: to_elixir_module(test_module.name),
      children: vscode_tests,
      file: file,
      errored: false
    }
  end
end
