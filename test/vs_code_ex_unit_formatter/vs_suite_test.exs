defmodule VSCodeExUnitFormatter.VsSuiteTest do
  use ExUnit.Case
  doctest VSCodeExUnitFormatter.VsSuite
  alias VSCodeExUnitFormatter.VsSuite
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
    test "when there are not tests in suite" do
      assert VsSuite.new(@exunit_module) == %VsSuite{
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
      assert %VsSuite{children: tests} = VsSuite.new(test_module)
      assert match?([%VsTestCase{} | _], tests)
    end
  end

  describe "append_child_suite/2" do
    test "appends child suite to parent" do
      parent_test_module = @exunit_module
      child_test_module = %{@exunit_module | tests: [@exunit_test]}

      parent_suite = VsSuite.new(parent_test_module)
      child_suite = VsSuite.new(child_test_module)

      assert %VsSuite{children: suite} = VsSuite.append_child_suite(parent_suite, child_suite)
      assert match?([%VsSuite{} | _], suite)
      assert match?([%VsTestCase{} | _], hd(suite).children)
    end
  end

  test "append_child_tests/2 - appends list of tests to a suite" do
    test_suite = VsSuite.new(@exunit_module)
    test_cases = [VsTestCase.new(@exunit_test), VsTestCase.new(@exunit_test)]

    assert %VsSuite{children: tests} = VsSuite.append_child_tests(test_suite, test_cases)
    assert match?([%VsTestCase{}, %VsTestCase{}], tests)
  end
end
