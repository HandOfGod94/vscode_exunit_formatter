defmodule VSCodeExUnitFormatter do
  use GenServer

  import VSCodeExUnitFormatter.ModuleHelpers

  @impl true
  def init(_opts) do
    tests = %{
      type: "suite",
      id: "root",
      label: "ExUnit",
      children: []
    }

    {:ok, tests}
  end

  @impl true
  def handle_cast({:suite_started, _opts}, tests) do
    {:noreply, tests}
  end

  def handle_cast({:suite_finished, _run_us, _load_us}, tests) do
    tests
    |> Jason.encode!(pretty: true)
    |> IO.puts()

    {:noreply, tests}
  end

  def handle_cast({:module_started, test_module}, tests) do
    vscode_tests =
      for test <- test_module.tests, into: [] do
        %{
          type: "test",
          id: "testid",
          label: test.name
        }
      end

    vscode_suite = %{
      type: "suite",
      id: module_id(test_module.name),
      label: to_elixir_module(test_module.name),
      children: vscode_tests
    }

    tests = %{tests | children: [vscode_suite | tests.children]}
    {:noreply, tests}
  end

  def handle_cast({:module_finished, _test_module}, config) do
    {:noreply, config}
  end

  def handle_cast({:test_started, _test}, config) do
    {:noreply, config}
  end

  def handle_cast({:test_finished, _test}, config) do
    {:noreply, config}
  end

  def handle_cast({:case_started, _test}, config) do
    {:noreply, config}
  end

  def handle_cast({:case_finished, _test}, config) do
    {:noreply, config}
  end
end
