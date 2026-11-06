#!/usr/bin/env bash
# Usage: WORLD=/work/world.sdf ./run_e2e.sh python3 /work/tests/e2e.py
set -eo pipefail
source /opt/ros/jazzy/setup.bash
set -u
: "${WORLD:?Set WORLD to an SDF file}"
(($#)) || { echo 'Pass the harness command as arguments' >&2; exit 2; }
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
OUT=${OUT:-/work/out}
mkdir -p "$OUT"
export DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-1}
pids=()

start() {
  local log=$1
  shift
  setsid "$@" >"$OUT/$log.log" 2>&1 &
  last_pid=$!
  pids+=("$last_pid")
}
stop_all() {
  local status=$? pid _
  trap - EXIT INT TERM
  set +e
  "$SCRIPT_DIR/cleanup.sh" || { ((status)) || status=1; }
  for pid in "${pids[@]}"; do kill -TERM -- "-$pid" 2>/dev/null || true; done
  for _ in {1..50}; do
    local running=0
    for pid in "${pids[@]}"; do kill -0 -- "-$pid" 2>/dev/null && running=1; done
    ((running)) || break
    sleep 0.1
  done
  for pid in "${pids[@]}"; do kill -KILL -- "-$pid" 2>/dev/null || true; done
  for _ in {1..20}; do
    local running=0
    for pid in "${pids[@]}"; do kill -0 -- "-$pid" 2>/dev/null && running=1; done
    ((running)) || break
    sleep 0.1
  done
  for pid in "${pids[@]}"; do
    if kill -0 -- "-$pid" 2>/dev/null; then
      echo "Service process group $pid survived cleanup" >&2
      ((status)) || status=1
    else
      wait "$pid" 2>/dev/null || true
    fi
  done
  exit "$status"
}
trap stop_all EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

wait_for() {
  local label=$1
  shift
  for _ in {1..100}; do
    kill -0 "$last_pid" 2>/dev/null || break
    if "$@" >/dev/null 2>&1; then
      kill -0 "$last_pid" 2>/dev/null && return 0
      break
    fi
    sleep 0.1
  done
  echo "Timed out waiting for $label; see $OUT" >&2
  return 1
}
port_ready() { (echo >"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }

# Reject stale services rather than connecting to a previous run's display/driver.
if xdpyinfo -display :99 >/dev/null 2>&1 || port_ready 4444; then
  echo 'Display :99 or WebDriver port 4444 is already in use' >&2
  exit 1
fi
if [[ ${WATCH:-0} == 1 ]] && { port_ready 5999 || port_ready 6080; }; then
  echo 'VNC/noVNC ports are already in use' >&2
  exit 1
fi
"$SCRIPT_DIR/cleanup.sh"
start xvfb Xvfb :99 -screen 0 1600x1000x24
wait_for Xvfb xdpyinfo -display :99
if [[ ${WATCH:-0} == 1 ]]; then
  start vnc x11vnc -display :99 -localhost -viewonly -forever -shared -rfbport 5999
  wait_for VNC port_ready 5999
  start novnc websockify --web /usr/share/novnc 6080 localhost:5999
  wait_for noVNC port_ready 6080
fi
gz sim --version >"$OUT/gazebo-version.log" 2>&1
start gazebo gz sim -s -r --headless-rendering "$WORLD"
# Add a world-specific readiness check before running the harness.
start webdriver tauri-driver --port 4444
wait_for WebDriver port_ready 4444
# Waiting on a background child lets Bash handle signals even if the harness hangs.
setsid "$@" &
harness_pid=$!
pids+=("$harness_pid")
wait "$harness_pid"
