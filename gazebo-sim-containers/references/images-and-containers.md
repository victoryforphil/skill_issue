# Images and containers

## Image recipe

Create two images, built for `linux/arm64` on Apple Silicon. Pin the ROS 2 Jazzy base by immutable image digest. In the simulator image, install Gazebo Harmonic and `ros-jazzy-ros-gz-bridge` from a dated, pinned ROS apt snapshot. Record the snapshot date and repository URL, package versions, image digest, and signing-key fingerprint in the build definition. Obtain the expected fingerprint independently from the official publisher and compare the full fingerprint before installing the key. Fail the build on a mismatch; do not invent a fingerprint or trust one fetched from the same endpoint as the key. Confirm that the chosen snapshot actually contains all required packages and dependencies. Pin the remaining apt sources too if reproducibility of the whole image matters.

Use `SHELL ["/bin/bash", "-o", "pipefail", "-c"]` in the Dockerfile. Download installers to a file with `curl --fail --location --proto '=https' --proto-redir '=https' --tlsv1.2 --output <file> <https-url>`, verify their published checksums or signatures, and then run them. Never pipe a download to a shell. Pin Rust, Node and any installer versions; check `gz sim --version` when tests depend on a specific version.

Layer a development image on the simulator image with Rust, Node, WebKitGTK development packages, `tauri-driver`, `WebKitWebDriver`, Xvfb, X11 utilities including `xdpyinfo`, x11vnc, noVNC, websockify, ffmpeg, xdotool, Python 3, `procps` and `util-linux` (`setsid`). Choose WebKitGTK packages compatible with the app and distribution. These are recipe requirements, not a tested Dockerfile or a set of verified pins.

## Per-task runtime

On macOS, check `docker context show`: Docker Desktop and OrbStack can both be installed. Give the selected VM enough CPU and memory (for example 32 GB on a 48 GB host). Changing memory requires a runtime restart that stops running containers. Warn other agents first and restart your own containers afterward.

Use one worktree, container, network, and noVNC port per task. Gazebo Transport uses UDP multicast for discovery; separate networks isolate agents. Also set a distinct `GZ_PARTITION` for worlds sharing a network. Substitute your own unique values in this host-shell example; `IMAGE` must be a prepared development image. Choose an unused host port such as 6000 plus an issue number, within the valid port range.

```bash
PREFIX=<your-prefix>
TASK=<your-task>
IMAGE=<your-dev-image>
PORT=<unused-host-port>
REPO=<absolute-worktree-path>
NAME="$PREFIX-$TASK"
docker network create "$NAME" || exit 1
docker run -d --init --name "$NAME" --network "$NAME" \
  -p "127.0.0.1:$PORT:6080" \
  -v "$REPO:/work" -v gazebo-cargo-registry:/root/.cargo/registry \
  -w /work -e CARGO_TARGET_DIR=/work/target-linux \
  -e CARGO_PROFILE_DEV_DEBUG=0 -e CARGO_PROFILE_TEST_DEBUG=0 \
  -e CARGO_INCREMENTAL=0 -e GZ_PARTITION="$NAME" \
  "$IMAGE" sleep infinity
```

If container creation fails, remove only the network you just created. Do not reuse or remove an existing name without checking its owner. When done, verify both names belong to your task, then run `docker rm -f "$NAME"` and `docker network rm "$NAME"`. Never touch another agent's resources. A shared Cargo registry volume caches downloads; `target-linux` prevents Linux and macOS builds from clobbering each other. Worktree build outputs can take 6–11 GB each; delete your task's target directory when the branch is finished.
