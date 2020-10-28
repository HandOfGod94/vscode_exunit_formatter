defmodule VSCodeExUnitFormatterTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias VSCodeExUnitFormatter.{VsSuite, VsTestCase}

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
    assert %VsSuite{type: "suite", id: "root", label: "ExUnit", children: [], errored: false} ==
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

  test "module_started- populates all the tests and test modules (vscode test suite)",
       %{root_test_suite: root_test_suite} do
    test_module = %{@exunit_module | tests: [@exunit_test]}

    assert {:noreply, %VsSuite{} = root_suite} =
             VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite)

    assert match?([%VsSuite{} | _], root_suite.children)
    assert match?([%VsTestCase{} | _], hd(root_suite.children).children)
  end

  describe "test_finished event" do
    test "for successful testcase", %{root_test_suite: root_test_suite} do
      test_module = %{@exunit_module | tests: [@exunit_test]}
      unit_test = %{@exunit_test | module: @exunit_module}

      {:noreply, root} =
        VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite)

      {:noreply, result} = VSCodeExUnitFormatter.handle_cast({:test_finished, unit_test}, root)

      assert %{children: [suite | _]} = result
      assert %{children: [test_case | _]} = suite
      assert test_case.errored == false
      assert test_case.skipped == false
      assert test_case.message =~ ""
    end

    test "for errored testcase", %{root_test_suite: root_test_suite} do
      test_module = %{@exunit_module | tests: [@exunit_test]}

      unit_test = %{
        @exunit_test
        | state: {:failed, [{:error, "I failed", []}]},
          module: @exunit_module
      }

      {:noreply, root} =
        VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite)

      {:noreply, result} = VSCodeExUnitFormatter.handle_cast({:test_finished, unit_test}, root)
      assert %{children: [suite | _]} = result
      assert %{children: [test_case | _]} = suite
      assert test_case.errored == true
      assert test_case.message =~ "I failed"
    end

    test "for skipped testcase", %{root_test_suite: root_test_suite} do
      test_module = %{@exunit_module | tests: [@exunit_test]}
      unit_test = %{@exunit_test | state: {:skipped, "this is skipped"}, module: @exunit_module}

      {:noreply, root} =
        VSCodeExUnitFormatter.handle_cast({:module_started, test_module}, root_test_suite)

      {:noreply, result} = VSCodeExUnitFormatter.handle_cast({:test_finished, unit_test}, root)

      assert %{children: [suite | _]} = result
      assert %{children: [test_case | _]} = suite
      assert test_case.skipped == true
    end
  end
end
