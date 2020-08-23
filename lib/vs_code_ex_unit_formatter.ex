defmodule VSCodeExUnitFormatter do
  use GenServer

  import VSCodeExUnitFormatter.ModuleHelpers

  @impl true
  def init(_opts) do
    root_test_suite = %{
      type: "suite",
      id: "root",
      label: "ExUnit",
      errored: false,
      children: []
    }

    {:ok, root_test_suite}
  end

  @impl true
  def handle_cast({:suite_started, _opts}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:suite_finished, _run_us, _load_us}, root_test_suite) do
    root_test_suite
    |> Jason.encode!(pretty: true)
    |> IO.puts()

    {:noreply, root_test_suite}
  end

  def handle_cast({:module_started, test_module}, root_test_suite) do
    vscode_tests =
      for test <- test_module.tests, into: [] do
        %{
          type: "test",
          id: Base.encode16(Atom.to_string(test.name)),
          label: test.name,
          file: test.tags.file,
          errored: false,
          skipped: false,
          line: test.tags.line
        }
      end

    vscode_suite = %{
      type: "suite",
      id: test_module.name,
      label: to_elixir_module(test_module.name),
      children: vscode_tests,
      errored: false
    }

    root_test_suite = %{root_test_suite | children: [vscode_suite | root_test_suite.children]}
    {:noreply, root_test_suite}
  end

  def handle_cast({:module_finished, %ExUnit.TestModule{} = test_module}, root_test_suite) do
    has_errored_state? = Enum.any?(test_module.tests, fn %{state: state} -> state == :failed end)

    updated_children =
      if has_errored_state? do
        Enum.map(root_test_suite.children, fn suite ->
          if suite.id == test_module.name,
            do: %{suite | errored: true},
            else: suite
        end)
      else
        root_test_suite.children
      end

    root_test_suite = %{root_test_suite | children: updated_children}
    {:noreply, root_test_suite}
  end

  def handle_cast({:test_started, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:test_finished, %ExUnit.Test{} = test}, root_test_suite) do
    test_id = Base.encode16(Atom.to_string(test.name))

    root_test_suite_children =
      Enum.reduce(root_test_suite.children, [], fn suite, root_children ->
        tests =
          Enum.reduce(suite.children, [], fn current_test, suite ->
            if current_test.id == test_id do
              current_test = %{current_test | skipped: match?({:skipped, _}, test.state) }
              current_test = %{current_test | errored: match?({:failed, _}, test.state) }
              [current_test | suite]
            else
              [current_test | suite]
            end
          end)

        new_suite = %{suite | children: tests}
        [new_suite | root_children]
      end)

    root_test_suite = %{root_test_suite | children: root_test_suite_children}
    {:noreply, root_test_suite}
  end

  def handle_cast({:case_started, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end

  def handle_cast({:case_finished, _test}, root_test_suite) do
    {:noreply, root_test_suite}
  end
end
