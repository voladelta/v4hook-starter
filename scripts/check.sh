#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

command -v forge >/dev/null 2>&1 || {
    echo "forge is required" >&2
    exit 1
}

forge fmt --check
forge build --sizes
forge test

if command -v slither >/dev/null 2>&1; then
    slither . --filter-paths 'vendor/' --fail-high
elif [ "${REQUIRE_SLITHER:-0}" = "1" ]; then
    echo "slither is required when REQUIRE_SLITHER=1" >&2
    exit 1
else
    echo "slither: skipped (set REQUIRE_SLITHER=1 to make it mandatory)" >&2
fi

if [ "${SKIP_APP:-0}" != "1" ]; then
    command -v bun >/dev/null 2>&1 || {
        echo "bun is required for app checks (or set SKIP_APP=1 for a contract-only task)" >&2
        exit 1
    }
    [ -x node_modules/.bin/tsc ] || {
        echo "run bun install --frozen-lockfile before ./scripts/check.sh" >&2
        exit 1
    }
    bun run typecheck
    bun run ui:build
fi
