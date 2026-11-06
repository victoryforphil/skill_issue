---
hash: "f2d4ccb74a5d36a77d7091c7d85891aecc871aa33fe4e6502005948593b9a44a"
name: gazebo-sim-containers
description: Run Gazebo and ROS 2 in isolated Linux containers on macOS, with headless or watchable desktop-app end-to-end tests.
---

# Gazebo simulator containers

Use this workflow to develop against a real Gazebo world in a Linux container, including ROS 2 and desktop UI tests. See [images and containers](references/images-and-containers.md) for image requirements and per-task Docker commands. Use a dedicated container and network for each task; never run the cleanup script in a shared container.

## Run and inspect

1. Build the web frontend on the host. Build the Linux desktop binary in the container with the app's production asset embedding enabled. Use the app's own build instructions.
2. Run `scripts/run_e2e.sh` **inside the container**, passing the harness command as arguments, e.g. `WORLD=/work/<world>.sdf scripts/run_e2e.sh python3 /work/<harness>.py`. The script sources ROS Jazzy before enabling nounset, cleans stale simulator processes, starts Xvfb and the headless simulator in separate sessions, starts `tauri-driver` on port 4444, and cleans up on exit. Install WebKitWebDriver where the driver can find it. The launcher rejects occupied display/driver ports and tracks the harness in its own process group so interruption can trigger bounded cleanup. Add a world-specific readiness check before the harness; a listening driver does not mean the world is ready. Logs go to `OUT` (default `/work/out`).
3. With `WATCH=1`, the script starts view-only x11vnc on container localhost port 5999 and noVNC on 6080. Open `http://127.0.0.1:<port>/vnc.html` on the Mac using the published loopback port. Never expose passwordless VNC to the LAN. For comparison, run `DISPLAY=:99 gz sim -g` on the same display.

`gz sim -s -r --headless-rendering <world>.sdf` runs the server without a GUI; cameras and GPU lidar still render offscreen. With no GPU, set `LIBGL_ALWAYS_SOFTWARE=1`; expect roughly 0.3 real-time factor and 30 fps viewports, depending on the machine. Start the server with `setsid` and keep its logs. Gazebo may ignore SIGTERM: send SIGINT, wait about five seconds, then SIGKILL and verify exit. `scripts/cleanup.sh` implements this for matching simulator and bridge processes inside the isolated container. Leftovers cause duplicate worlds and flaky tests. Avoid `pkill -f "gz sim"` inside a `docker exec bash -lc` command containing that text: it can kill its own shell. Use script files and narrow matches instead. Keep builds and package installs out of the cleanup phase too: full-command-line matching can catch a package name containing `gz-sim`.

Inspect the live world with `gz topic -l`, `gz topic -e -t /world/<w>/stats -n 1`, `gz service -l`, `gz service -i -s <srv>`, and `gz model --list`. Call `/world/<w>/generate_world_sdf` with its documented request including `expand_include_tags` to inspect models from `<include>`; Fuel includes need network access or a warm cache.

## Assert real behavior

Drive the app under Xvfb with WebDriver and a Python harness. The harness must create a WebDriver session with app-specific capabilities pointing to the built binary. Do not mock the simulator: assert each end-to-end feature against live CLI, topics, services, or poses. For example, verify a spawned model in `gz model --list`, compare pose samples after a move, and check that reset advances the epoch and clears history. Wait for the app shell before checking theme or state. For React-controlled inputs, use the native value setter and dispatch an input event; WebDriver `clear()` alone may not update React. Select text on focus. Save light and dark screenshots for the PR or README, and print one PASS/FAIL line per step with key numbers. Put each feature's steps in its own module to reduce parallel conflicts.

A small headless probe against the live world is a faster first loop: exit 1 on probe errors and 2 on failed assertions. Run the full UI suite afterward.

## ROS and shutdown

Source `/opt/ros/jazzy/setup.bash` before `set -u`; ROS setup reads unset variables. Use `ros_gz_bridge` for topic bridging. Start `ros2 topic echo --once <topic> <type>` in the background before publishing, then compare parsed numeric values rather than YAML text. Bound the wait.

For Rust `r2r` and similar clients, stop the spin task first, then drop publishers and subscriptions, then the node. Bound each shutdown wait; otherwise the process can abort, segfault, or hang on exit.

## Parallel integration and remote worlds

Give each agent its own worktree, container, network, and noVNC port. Each agent runs its suites and attaches screenshots to its PR. The integrator reruns suites on the PR merged onto current main in a separate container, merges only when CI is green, and removes its own worktree and build output.

Across hosts, `GZ_IP` selects the interface and `GZ_RELAY` relays discovery only. Data endpoints still need bidirectional reachability, often unavailable through NAT or macOS VM networks. Gazebo's WebsocketServer (gz-launch, port 9002, authentication keys) targets browser visualization. For full control from a native Mac app, place a small gateway beside Gazebo and publish its single TCP port on `127.0.0.1` or tunnel it over SSH.

## Official references

- [Transport relay](https://gazebosim.org/api/transport/13/relay.html)
- [Transport environment variables](https://gazebosim.org/api/transport/15/envvars.html)
- [Web visualization](https://gazebosim.org/docs/harmonic/web_visualization/)
- [Installing on macOS](https://gazebosim.org/docs/harmonic/install_osx)
