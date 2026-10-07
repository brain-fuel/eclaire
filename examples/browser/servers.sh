#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
state_dir="$root/build/servers"
mkdir -p "$state_dir"

port_for() {
  case "$1" in
    c) echo "${PORT_C:-5092}" ;;
    fsharp) echo "${PORT_FSHARP:-5093}" ;;
    haskell) echo "${PORT_HASKELL:-5094}" ;;
  esac
}

url_for() {
  echo "http://127.0.0.1:$(port_for "$1")/"
}

wait_for_url() {
  python3 - "$1" <<'PY'
import sys
import time
import urllib.error
import urllib.request

url = sys.argv[1]
for _ in range(100):
    try:
        urllib.request.urlopen(url, timeout=1).read(1)
        break
    except (urllib.error.URLError, TimeoutError):
        time.sleep(0.1)
else:
    raise SystemExit(1)
PY
}

pid_file() { echo "$state_dir/$1.pid"; }
log_file() { echo "$state_dir/$1.log"; }

stop_tree() {
  local pid="$1" child children
  children="$(pgrep -P "$pid" 2>/dev/null || true)"
  for child in $children; do stop_tree "$child"; done
  kill -TERM "$pid" 2>/dev/null || true
  for _ in {1..30}; do
    kill -0 "$pid" 2>/dev/null || return 0
    sleep 0.1
  done
  kill -KILL "$pid" 2>/dev/null || true
}

stop_service() {
  local service="$1" pidfile marker pid command_line
  pidfile="$(pid_file "$service")"
  marker="$state_dir/$service.stopping"
  if [[ ! -f "$pidfile" ]]; then
    rm -f "$marker"
    echo "$service is not managed by this Makefile. If it was started manually, stop it with Ctrl-C in its terminal."
    return 0
  fi
  pid="$(cat "$pidfile")"
  if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$pidfile"
    rm -f "$marker"
    echo "$service was already stopped (removed stale pid file)"
    return 0
  fi
  command_line="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  case "$service:$command_line" in
    c:*"http.server "*"examples/c/browser/static"* | \
    haskell:*"http.server "*"examples/haskell/browser/public"* | \
    fsharp:*"dotnet run --no-build --no-launch-profile"*"ElmishClay.Browser.fsproj"*)
      : >"$marker"
      stop_tree "$pid"
      rm -f "$pidfile"
      rm -f "$marker"
      echo "$service stopped"
      ;;
    *)
      echo "Refusing to stop pid $pid: it no longer matches the recorded $service launcher. Check $pidfile and $(log_file "$service")." >&2
      return 1
      ;;
  esac
}

start_service() {
  local service="$1" port pidfile logfile pid
  port="$(port_for "$service")"
  pidfile="$(pid_file "$service")"
  logfile="$(log_file "$service")"
  rm -f "$state_dir/$service.stopping"
  if [[ -f "$pidfile" ]]; then
    pid="$(cat "$pidfile")"
    if kill -0 "$pid" 2>/dev/null; then
      if wait_for_url "$(url_for "$service")"; then
        echo "$service already serving at $(url_for "$service") (pid $pid)"
        return 0
      fi
      echo "$service process $pid exists but is not answering at $(url_for "$service"). See $logfile" >&2
      return 1
    fi
    rm -f "$pidfile"
  fi
  if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Port $port is already in use by an unmanaged process; stop it in its original terminal or choose another port." >&2
    return 1
  fi
  case "$service" in
    c)
      nohup python3 -m http.server "$port" --bind 127.0.0.1 --directory "$root/examples/c/browser/static" >"$logfile" 2>&1 </dev/null &
      ;;
    fsharp)
      nohup dotnet run --no-build --no-launch-profile --project "$root/examples/fsharp/browser/ElmishClay.Browser.fsproj" --urls "http://127.0.0.1:$port" >"$logfile" 2>&1 </dev/null &
      ;;
    haskell)
      nohup python3 -m http.server "$port" --bind 127.0.0.1 --directory "$root/examples/haskell/browser/public" >"$logfile" 2>&1 </dev/null &
      ;;
    *) echo "Unknown service: $service" >&2; return 2 ;;
  esac
  pid=$!
  printf '%s\n' "$pid" >"$pidfile"
  if wait_for_url "$(url_for "$service")"; then
    echo "$service serving at $(url_for "$service") (pid $pid)"
  else
    echo "$service did not start; log: $logfile" >&2
    cat "$logfile" >&2
    stop_service "$service"
    return 1
  fi
}

supervise_services() {
  local service pidfile pid
  trap 'exit 0' INT TERM
  echo 'Servers are supervised. Press Ctrl-C here or run make stop from another terminal.'
  while true; do
    local any_running=0
    for service in $supervised_services; do
      pidfile="$(pid_file "$service")"
      if [[ -f "$pidfile" ]]; then
        any_running=1
        pid="$(cat "$pidfile")"
        if ! kill -0 "$pid" 2>/dev/null; then
          if [[ -f "$state_dir/$service.stopping" ]]; then
            continue
          fi
          echo "$service server exited unexpectedly; stopping remaining managed servers."
          return 1
        fi
      fi
    done
    if [[ "$any_running" == 0 ]]; then
      echo 'All managed servers stopped.'
      return 0
    fi
    sleep 0.5
  done
}

cleanup_supervised_services() {
  trap - EXIT
  local service
  for service in $supervised_services; do
    if [[ -f "$(pid_file "$service")" ]]; then stop_service "$service" || true; fi
  done
}

status_service() {
  local service="$1" pidfile pid
  pidfile="$(pid_file "$service")"
  if [[ -f "$pidfile" ]]; then
    pid="$(cat "$pidfile")"
    if kill -0 "$pid" 2>/dev/null && wait_for_url "$(url_for "$service")"; then
      echo "$service running at $(url_for "$service") (pid $pid)"
      return 0
    fi
  fi
  echo "$service stopped"
}

mode="${1:-}"
target="${2:-all}"
case "$mode:$target" in
  start:c | start:fsharp | start:haskell)
    supervised_services="$target"
    trap cleanup_supervised_services EXIT
    start_service "$target"
    supervise_services
    ;;
  start:all)
    supervised_services='c fsharp haskell'
    trap cleanup_supervised_services EXIT
    start_service c
    if ! start_service fsharp; then stop_service c; exit 1; fi
    if ! start_service haskell; then stop_service fsharp; stop_service c; exit 1; fi
    supervise_services
    ;;
  stop:c | stop:fsharp | stop:haskell) stop_service "$target" ;;
  stop:all) stop_service c; stop_service fsharp; stop_service haskell ;;
  status:c | status:fsharp | status:haskell) status_service "$target" ;;
  status:all) status_service c; status_service fsharp; status_service haskell ;;
  *) echo "Usage: $0 {start|stop|status} [all|c|fsharp|haskell]" >&2; exit 2 ;;
esac
