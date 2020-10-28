# VSCodeExUnitFormatter

> WIP

[![pipeline](https://github.com/HandOfGod94/vscode_exunit_formatter/workflows/pipeline/badge.svg)](https://github.com/HandOfGod94/vscode_exunit_formatter/actions?query=workflow%3Apipeline)


## Dev setup

```sh
# run tests with coverage
mix run --cover

# run credo
mix credo --strict

# create archive
mix do archive.build, archive.install

# to run with test formatter
mix test --formatter VSCodeExUnitFormatter
```

> This reporter has to be used in conjunction with
> [vscode-exunit-test-adapter](https://github.com/HandOfGod94/vscode-exunit-test-adapter)