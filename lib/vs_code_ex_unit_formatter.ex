defmodule VSCodeExUnitFormatter do
  @moduledoc false

  use GenServer
  import ExUnit.Formatter, only: [format_test_failure: 5]
  alias VSCodeExUnitFormatter.VsSuite

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
    vscode_suite = VsSuite.populate_suite(test_module)
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
