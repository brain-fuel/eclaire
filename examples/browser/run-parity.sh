#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

pick_port() {
  python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()'
}
port_c="${1:-$(pick_port)}"
port_fsharp="${2:-$(pick_port)}"
port_haskell="${3:-$(pick_port)}"
log_dir="$(mktemp -d)"
pid_c=''
pid_fsharp=''
pid_haskell=''

cleanup() {
  if [[ -n "$pid_fsharp" ]]; then
    for child_pid in $(pgrep -P "$pid_fsharp" 2>/dev/null || true); do
      kill "$child_pid" 2>/dev/null || true
    done
  fi
  for pid in "$pid_c" "$pid_fsharp" "$pid_haskell"; do
    if [[ -n "$pid" ]]; then kill "$pid" 2>/dev/null || true; fi
  done
  for pid in "$pid_c" "$pid_fsharp" "$pid_haskell"; do
    if [[ -n "$pid" ]]; then wait "$pid" 2>/dev/null || true; fi
  done
  if [[ "${KEEP_PARITY_LOGS:-0}" == 1 ]]; then
    echo "Parity server logs: $log_dir"
  else
    rm -rf "$log_dir"
  fi
}
trap cleanup EXIT INT TERM

python3 -m http.server "$port_c" -d examples/c/browser/static >"$log_dir/c.log" 2>&1 &
pid_c=$!
dotnet run --no-build --no-launch-profile --project examples/fsharp/browser/Eclaire.Browser.fsproj --urls "http://127.0.0.1:$port_fsharp" >"$log_dir/fsharp.log" 2>&1 &
pid_fsharp=$!
python3 -m http.server "$port_haskell" -d examples/haskell/browser/public >"$log_dir/haskell.log" 2>&1 &
pid_haskell=$!

python3 - "$port_c" "$port_fsharp" "$port_haskell" <<'PY'
import sys
import time
import urllib.error
import urllib.request

for port in sys.argv[1:]:
    url = f"http://127.0.0.1:{port}/"
    for _ in range(100):
        try:
            urllib.request.urlopen(url, timeout=1).read(1)
            break
        except (urllib.error.URLError, TimeoutError):
            time.sleep(0.1)
    else:
        raise SystemExit(f"Demo server did not start: {url}")
PY

PORT_C="$port_c" PORT_FSHARP="$port_fsharp" PORT_HASKELL="$port_haskell" \
  node examples/browser/parity.mjs
