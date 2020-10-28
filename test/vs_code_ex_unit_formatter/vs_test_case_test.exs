defmodule VSCodeExUnitFormatter.VsTestCaseTest do
  use ExUnit.Case
  doctest VSCodeExUnitFormatter.VsTestCase
  alias VSCodeExUnitFormatter.VsTestCase

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

  describe "new/1" do
    test "creates vscode test format struct" do
      assert %VsTestCase{
               errored: false,
               file: file,
               id: "7465737420666F6F20626172",
               label: :"test foo bar",
               line: 15,
               message: "",
               skipped: false,
               type: "test"
             } = VsTestCase.new(@exunit_test)

      assert file != ""
    end
  end

  describe "update_state_from_exunit/2" do
    test "updates vs_test state to skipped when exunit test is skipped" do
      vs_test = VsTestCase.new(@exunit_test)
      test_case = %{@exunit_test | state: {:skipped, "this is skipped"}}

      updated_vs_test = VsTestCase.update_state_from_exunit(vs_test, test_case)
      assert updated_vs_test.skipped == true
    end

    test "updates vs_test state to error when exunit test is errored" do
      vs_test = VsTestCase.new(@exunit_test)

      test_case = %{
        @exunit_test
        | state: {:failed, [{:error, "I failed", []}]},
          module: @exunit_module
      }

      updated_vs_test = VsTestCase.update_state_from_exunit(vs_test, test_case)
      assert updated_vs_test.errored == true
      assert updated_vs_test.message =~ "I failed"
    end

    test "vs_test state remains same when exunit passes" do
      vs_test = VsTestCase.new(@exunit_test)
      test_case = %{@exunit_test | state: nil}
      updated_vs_test = VsTestCase.update_state_from_exunit(vs_test, test_case)
      assert vs_test == updated_vs_test
    end
  end
end
