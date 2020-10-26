defmodule VSCodeExUnitFormatter.VsSuiteTest do
  use ExUnit.Case
  doctest VSCodeExUnitFormatter.VsSuite
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

  describe "populate_suite/1" do
    test "when there are not tests in suite" do
      assert VsSuite.populate_suite(@exunit_module) == %VsSuite{
               type: "suite",
               id: Example.Fizz,
               label: :"Example.Fizz",
               errored: false,
               file: "",
               children: []
             }
    end

    test "returns VScode test adapter format attrubutes when there are tests in suite" do
      test_module = %{@exunit_module | tests: [@exunit_test]}
      assert %VsSuite{children: tests} = VsSuite.populate_suite(test_module)
      assert match?([%VsTestCase{} | _], tests)
    end
  end
end
