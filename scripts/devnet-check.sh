#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
started=0

cleanup() {
    if [ "$started" = "1" ]; then
        started=0
        "$root/scripts/devnet-down.sh"
    fi
}

on_signal() {
    cleanup
    trap - EXIT
    exit 130
}

trap cleanup EXIT
trap on_signal HUP INT TERM

"$root/scripts/devnet-up.sh"
started=1
"$root/scripts/devnet-deploy.sh"

cd "$root"
bun run scenario:devnet

cleanup
trap - EXIT HUP INT TERM
echo "DEVNET_OK"
