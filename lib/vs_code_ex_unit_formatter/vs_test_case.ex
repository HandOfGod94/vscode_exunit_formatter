defmodule VSCodeExUnitFormatter.VsTestCase do
  import ExUnit.Formatter, only: [format_test_failure: 5]

  @derive Jason.Encoder
  defstruct [
    :id,
    :label,
    :file,
    :line,
    :message,
    type: "test",
    skipped: false,
    errored: false
  ]

  def new(%ExUnit.Test{} = test_case) do
    %__MODULE__{
      type: "test",
      id: Base.encode16(Atom.to_string(test_case.name)),
      label: test_case.name,
      file: test_case.tags.file,
      message: "",
      line: test_case.tags.line
    }
  end

  def update_state_from_exunit(%__MODULE__{} = vs_test, %ExUnit.Test{} = exunit_test) do
    case exunit_test do
      %{state: {:skipped, _}} ->
        %{vs_test | skipped: true}

      %{state: {:failed, reason}} ->
        message = format_test_failure(exunit_test, reason, 1, 80, &formatter(&1, &2))
        %{vs_test | errored: true, message: message}

      _ ->
        vs_test
    end
  end

  defp formatter(:error_info, msg), do: msg

  defp formatter(_, msg), do: msg
end
