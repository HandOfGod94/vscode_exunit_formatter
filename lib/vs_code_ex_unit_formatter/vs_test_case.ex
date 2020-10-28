defmodule VSCodeExUnitFormatter.VsTestCase do
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
end
