#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
pid_file="$root/.devnet/anvil.pid"
ui_manifest="$root/ui/public/deployment.json"

rm -f -- "$ui_manifest"

if [ ! -f "$pid_file" ]; then
    echo "devnet is not running"
    exit 0
fi

pid=$(sed -n '1p' "$pid_file")
command_line=$(ps -p "$pid" -o command= 2>/dev/null || true)
case "$command_line" in
    *anvil*) ;;
    *)
        echo "refusing to stop PID $pid because it is not anvil" >&2
        exit 1
        ;;
esac

kill "$pid"
attempt=0
while kill -0 "$pid" 2>/dev/null; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 50 ]; then
        echo "anvil PID $pid did not stop" >&2
        exit 1
    fi
    sleep 0.1
done

rm -f -- "$pid_file"
echo "devnet stopped"
