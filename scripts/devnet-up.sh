#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
state="$root/.devnet"
pid_file="$state/anvil.pid"
log_file="$state/anvil.log"
port=${DEVNET_PORT:-8545}
chain_id=${DEVNET_CHAIN_ID:-31337}
mnemonic="test test test test test test test test test test test junk"

command -v anvil >/dev/null 2>&1 || {
    echo "anvil is required" >&2
    exit 1
}
command -v cast >/dev/null 2>&1 || {
    echo "cast is required" >&2
    exit 1
}

mkdir -p -- "$state"
if [ -f "$pid_file" ] && kill -0 "$(sed -n '1p' "$pid_file")" 2>/dev/null; then
    echo "devnet already running on PID $(sed -n '1p' "$pid_file")" >&2
    exit 1
fi

anvil \
    --host 127.0.0.1 \
    --port "$port" \
    --chain-id "$chain_id" \
    --accounts 100 \
    --balance 100000 \
    --mnemonic "$mnemonic" \
    --silent >"$log_file" 2>&1 &
pid=$!
printf '%s\n' "$pid" >"$pid_file"

rpc_url="http://127.0.0.1:$port"
attempt=0
while ! cast chain-id --rpc-url "$rpc_url" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 50 ]; then
        kill "$pid" 2>/dev/null || true
        echo "anvil did not become ready; inspect $log_file" >&2
        exit 1
    fi
    sleep 0.1
done

cat >"$state/config.env" <<EOF
DEVNET_RPC_URL=$rpc_url
DEVNET_CHAIN_ID=$chain_id
DEVNET_MNEMONIC=$mnemonic
EOF

echo "devnet ready at $rpc_url with PID $pid and 100 disposable accounts"
