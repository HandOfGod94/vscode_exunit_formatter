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
      assert VsTestCase.new(@exunit_test) == %VsTestCase{
               errored: false,
               file:
                 "/Users/gahanrakholia/workspace/nuke/vscode_exunit_formatter/test/vs_code_ex_unit_formatter/vs_test_case_test.exs",
               id: "7465737420666F6F20626172",
               label: :"test foo bar",
               line: 15,
               message: "",
               skipped: false,
               type: "test"
             }
    end
  end
end
