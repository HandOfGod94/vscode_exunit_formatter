defmodule VSCodeExUnitFormatter do
  use GenServer

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
    vscode_suite = %{
      type: "suite",
      id: "foo",
      label: test_module.name
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
