defmodule VSCodeExUnitFormatter do
  use GenServer

  import VSCodeExUnitFormatter.ModuleHelpers
  import ExUnit.Formatter, only: [format_test_failure: 5]

  @moduledoc false

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

  def handle_cast({:module_started, %ExUnit.TestModule{} = test_module}, root_test_suite) do
    vscode_tests =
      for test <- test_module.tests, into: [] do
        %{
          type: "test",
          id: Base.encode16(Atom.to_string(test.name)),
          label: test.name,
          file: test.tags.file,
          errored: false,
          skipped: false,
          message: "",
          line: test.tags.line
        }
      end

    file =
      if vscode_tests != [] do
        vscode_tests |> Enum.at(0) |> Map.get(:file)
      else
        ""
      end

    vscode_suite = %{
      type: "suite",
      id: test_module.name,
      label: to_elixir_module(test_module.name),
      children: vscode_tests,
      file: file,
      errored: false
    }

    root_test_suite = %{root_test_suite | children: [vscode_suite | root_test_suite.children]}
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
        %{
          suite
          | children:
              Enum.map(suite.children, fn vs_test ->
                with %{id: id} when id == test_id <- vs_test,
                     %{state: {:failed, reason}} <- test do
                  message = format_test_failure(test, reason, 1, 80, &formatter(&1, &2))
                  %{vs_test | message: message, errored: true}
                else
                  %{state: {:skipped, _}} -> %{vs_test | skipped: true}
                  _ -> vs_test
                end
              end)
        }
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

  defp formatter(:error_info, msg), do: msg

  defp formatter(_, msg), do: msg
end
