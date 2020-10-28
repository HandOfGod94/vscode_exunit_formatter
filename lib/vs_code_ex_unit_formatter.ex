defmodule VSCodeExUnitFormatter do
  @moduledoc false

  use GenServer
  alias VSCodeExUnitFormatter.VsSuite
  alias VSCodeExUnitFormatter.VsTestCase

  @impl GenServer
  def init(_opts) do
    root_test_suite = %VsSuite{id: "root", label: "ExUnit"}
    {:ok, root_test_suite}
  end

  @impl GenServer
  def handle_cast({:suite_started, _opts}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:suite_finished, _run_us, _load_us}, root_test_suite) do
    root_test_suite
    |> Jason.encode!(pretty: true)
    |> IO.puts()

    {:noreply, root_test_suite}
  end

  def handle_cast({:module_started, %ExUnit.TestModule{} = test_module}, root_test_suite) do
    vscode_suite = VsSuite.new(test_module)
    root_test_suite = VsSuite.append_child_suite(root_test_suite, vscode_suite)
    {:noreply, root_test_suite}
  end

  def handle_cast({:module_finished, _test_module}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:test_started, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:test_finished, %ExUnit.Test{} = test}, root_test_suite) do
    test_id = Base.encode16(Atom.to_string(test.name))

    root_suite_children =
      Enum.map(root_test_suite.children, fn suite ->
        %{suite | children: update_test_state(suite, test, test_id)}
      end)

    root_test_suite = %{root_test_suite | children: root_suite_children}
    {:noreply, root_test_suite}
  end

  def handle_cast({:case_started, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:case_finished, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  defp update_test_state(%VsSuite{} = suite, %ExUnit.Test{} = test, test_id) do
    suite.children
    |> Enum.filter(fn vs_test -> vs_test.id == test_id end)
    |> Enum.map(&VsTestCase.update_state_from_exunit(&1, test))
  end
end
