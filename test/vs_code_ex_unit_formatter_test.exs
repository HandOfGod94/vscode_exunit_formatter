defmodule VSCodeExUnitFormatterTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, root_test_suite} = VSCodeExUnitFormatter.init([])
    %{root_test_suite: root_test_suite}
  end

  test "init/1- initlizes root ExUnit test suite for VScode", %{root_test_suite: root_test_suite} do
    assert %{type: "suite", id: "root", label: "ExUnit", children: [], errored: false} ==
             root_test_suite
  end

  test "suite_started - do nothing", %{root_test_suite: root_test_suite} do
    assert VSCodeExUnitFormatter.handle_cast({:suite_started, []}, root_test_suite) ==
             {:noreply, root_test_suite}
  end

  test "suite_finished - prints suite results in json format"
  test "module_started- populates all the tests and test modules (vscode test suite)"
  test "module_finished - marks module as failed if any of the child tests have failed"
  test "test_started - update test state to skipped when test is skipped"

  describe "test_finished event" do
    test "for successful testcase"
    test "for errored testcase"
    test "for skipped testcase"
    test "captures error stacktrace as message when test fails"
  end
end
