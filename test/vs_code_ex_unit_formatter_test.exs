defmodule VSCodeExUnitFormatterTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @exunit_module %ExUnit.TestModule{
    name: :"Elixir.Example.Fizz",
    state: nil,
    tests: []
  }

  @exunit_test %ExUnit.Test{
    name: :"test foo bar",
    module: @exunit_module,
    state: nil,
    tags: %{
      file: __ENV__.file,
      line: 15
    },
    logs: ""
  }

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

  test "suite_finished - prints suite results in json format", %{root_test_suite: root_test_suite} do
    assert capture_io(fn ->
             VSCodeExUnitFormatter.handle_cast({:suite_finished, 0, 1}, root_test_suite)
           end) =~ ~s("label": "ExUnit")
  end

  test "module_started- populates all the tests and test modules (vscode test suite)", %{
    root_test_suite: root_test_suite
  } do
    test_module = %{@exunit_module | tests: [@exunit_test]}

    assert VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite) ==
             {:noreply,
              %{
                children: [
                  %{
                    children: [
                      %{
                        errored: false,
                        file:
                          "/Users/gahanrakholia/workspace/nuke/vscode_exunit_formatter/test/vs_code_ex_unit_formatter_test.exs",
                        id: "7465737420666F6F20626172",
                        label: :"test foo bar",
                        line: 15,
                        message: "",
                        skipped: false,
                        type: "test"
                      }
                    ],
                    errored: false,
                    id: Example.Fizz,
                    label: :"Example.Fizz",
                    type: "suite"
                  }
                ],
                errored: false,
                id: "root",
                label: "ExUnit",
                type: "suite"
              }}
  end

  describe "test_finished event" do
    test "for successful testcase"
    test "for errored testcase"
    test "for skipped testcase", %{root_test_suite: root_test_suite} do
      test_module = %{@exunit_module | tests: [@exunit_test]}
      unit_test = %{@exunit_test | state: {:skipped, "this is skipped"}, module: @exunit_module}
      {:noreply, root} = VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite)
      {:noreply, result} = VSCodeExUnitFormatter.handle_cast({:test_finished, unit_test}, root)
      assert true == result.children |> Enum.at(0) |> Map.get(:children) |> Enum.at(0) |> Map.get(:skipped)
    end
    test "captures error stacktrace as message when test fails"
  end
end
