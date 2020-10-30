# VSCodeExUnitFormatter

[![pipeline](https://github.com/HandOfGod94/vscode_exunit_formatter/workflows/pipeline/badge.svg)](https://github.com/HandOfGod94/vscode_exunit_formatter/actions?query=workflow%3Apipeline)
[![codecov](https://codecov.io/gh/HandOfGod94/vscode_exunit_formatter/branch/master/graph/badge.svg?token=IWHKKFA29Q)](https://codecov.io/gh/HandOfGod94/vscode_exunit_formatter)

> WIP

## Overview

VSCode Test extension is useful to run and debug tests quickly across any project for any language.
This project aims to format test results in such a way that test adapter can recognize it and thus enables
running tests from VSCode test adapter.

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