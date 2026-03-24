#!/bin/sh
#/ `script/generate.sh` runs `go generate` on repo.
#/ It also runs `script/run-check-structfield-settings.sh -fix` to keep linter
#/ exceptions in `.golangci.yml` up to date.
#/ `script/generate.sh --check` checks that the generated files are up to date.

set -e

CDPATH="" cd -- "$(dirname -- "$0")/.."

if [ "$1" = "--check" ]; then
  export CHECK=1
fi

go generate ./...

script/run-check-structfield-settings.sh -fix