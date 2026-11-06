#!/usr/bin/env bash
# Run only inside this task's isolated container.
set -uo pipefail

if [[ ! -f /.dockerenv && ! -f /run/.containerenv ]]; then
  echo 'Refusing cleanup outside a container' >&2
  exit 1
fi

# Exclude this script and every ancestor, including docker exec shells whose
# command lines may contain the search pattern.
ancestors=" $$ "
pid=$$
while [[ "$pid" != 1 && "$pid" != 0 ]]; do
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ') || exit 1
  [[ "$pid" =~ ^[0-9]+$ ]] || break
  ancestors+="$pid "
done

# Do not count zombies: they are already dead and await their parent's wait().
alive() {
  local state
  state=$(ps -o stat= -p "$1" 2>/dev/null) || return 1
  [[ -n "$state" && "$state" != Z* ]]
}

# Keep the container idle except for simulator processes during cleanup.
# Full command lines can also match builds or package names containing gz-sim.
matches=()
while IFS= read -r pid; do
  [[ " $ancestors " == *" $pid "* ]] || matches+=("$pid")
done < <(pgrep -f 'gz sim|gz-sim|parameter_bridge' || true)

((${#matches[@]})) || exit 0
kill -INT "${matches[@]}" 2>/dev/null || true
deadline=$((SECONDS + 5))
while ((SECONDS < deadline)); do
  alive=()
  for pid in "${matches[@]}"; do alive "$pid" && alive+=("$pid"); done
  ((${#alive[@]})) || exit 0
  sleep 0.1
done
kill -KILL "${alive[@]}" 2>/dev/null || true
deadline=$((SECONDS + 2))
while ((SECONDS < deadline)); do
  remaining=()
  for pid in "${alive[@]}"; do alive "$pid" && remaining+=("$pid"); done
  ((${#remaining[@]})) || exit 0
  sleep 0.1
done
echo "Simulator processes survived cleanup: ${remaining[*]}" >&2
exit 1
