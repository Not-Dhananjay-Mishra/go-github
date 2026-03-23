#!/bin/sh
#/ script/test.sh runs tests on each go module in go-github. Arguments are passed to each go test invocation.
#/ "-race -covermode atomic ./..." is used when no arguments are given.
#/
#/ When UPDATE_GOLDEN is set, all directories named "golden" are removed before running tests.

CDPATH="" cd -- "$(dirname -- "$0")/.."

if [ "$#" = "0" ]; then
  set -- -race -covermode atomic ./...
fi

if [ -n "$UPDATE_GOLDEN" ]; then
  find . -name golden -type d -exec rm -rf {} +
fi

MOD_DIRS="$(git ls-files '*go.mod' | xargs dirname | sort)"

PIDS=""
for dir in $MOD_DIRS; do
  [ "$dir" = "example/newreposecretwithlibsodium" ] && continue
  echo "testing $dir"
  (
    cd "$dir"
    go test "$@"
  ) &
  PIDS="$PIDS $!:$dir"
done

FAILED=""
for entry in $PIDS; do
  pid="${entry%%:*}"
  dir="${entry##*:}"
  wait "$pid" || { echo "FAILED: $dir"; FAILED=1; }
done

[ -n "$FAILED" ] && exit 1