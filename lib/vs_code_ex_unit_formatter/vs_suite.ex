defmodule VSCodeExUnitFormatter.VsSuite do
  import VSCodeExUnitFormatter.ModuleHelpers
  alias ExUnit.TestModule
  alias VSCodeExUnitFormatter.VsTestCase

  @derive Jason.Encoder
  defstruct [:id, :label, type: "suite", children: [], file: "", errored: false]

  def new(%TestModule{} = test_module) do
    vscode_tests =
      test_module.tests
      |> Enum.map(&VsTestCase.new/1)
      |> Enum.into([])

    %__MODULE__{
      type: "suite",
      id: test_module.name,
      label: to_elixir_module(test_module.name),
      children: vscode_tests,
      file: get_file_name(vscode_tests),
      errored: false
    }
  end

  def append_child_suite(%__MODULE__{} = parent_suite, %__MODULE__{} = child_suite) do
    new_children = [child_suite | parent_suite.children]
    %{parent_suite | children: new_children}
  end

  def append_child_tests(%__MODULE__{} = parent_suite, vs_test_cases)
      when is_list(vs_test_cases) do
    new_children = parent_suite.children ++ vs_test_cases
    %{parent_suite | children: new_children}
  end

  defp get_file_name([%VsTestCase{} = test | _]), do: test.file
  defp get_file_name(_), do: ""
end
