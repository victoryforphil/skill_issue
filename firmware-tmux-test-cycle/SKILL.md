---
name: firmware-tmux-test-cycle
description: Use when testing Loki firmware on the two Makerfabs ESP32 UWB boards with tmux, firmware_buddy serial consoles, west flash, or staged hardware test handoffs.
---

# Firmware tmux test cycle

Use this skill when preparing or running hardware tests for Loki firmware on the
two Makerfabs ESP32 UWB boards.

## Hardware

Use the fixed serial ports unless the user says otherwise:

```text
Board 1 / anchor: /dev/cu.usbserial-02CC2FF0
Board 2 / tag:    /dev/cu.usbserial-02CC300D
```

## Roles

Subagents prepare builds and handoff instructions. The orchestrating agent owns
hardware access.

Subagents should not flash, open serial consoles, kill serial processes, or send
commands to the boards unless explicitly asked. They should return:

- Files changed.
- Build command.
- Flash command for each board.
- Serial console commands.
- Exact board shell commands to run.
- Expected output.
- Failure logs they need for the next round.

The orchestrating agent gates tests sequentially because all tracks share the
same two boards and serial ports.

## tmux session

Reuse one tmux session named `loki`.

Create it only if missing:

```sh
tmux new-session -d -s loki
```

List panes:

```sh
tmux list-panes -t loki -F '#{pane_id} #{pane_current_command} #{pane_title}'
```

Start or reuse two panes for serial consoles:

```sh
cargo run -p firmware_buddy -- serial --tty /dev/cu.usbserial-02CC2FF0
cargo run -p firmware_buddy -- serial --tty /dev/cu.usbserial-02CC300D
```

When the user requests Rerun-backed testing, use `firmware_buddy` serial or
capture with `--rerun`. Prefer `--rerun-save` when the output should be kept as
a recording for later review.

Use `tmux send-keys -t <pane-id> '<command>' Enter` for board shell commands.
Use `tmux capture-pane -p -t <pane-id> -S -200` for recent serial output.

## Releasing ports before flash

Before flashing either board, release serial ports:

```sh
pkill -9 firmware_buddy || true; sleep 1
```

Then flash one board at a time. Do not flash while `firmware_buddy` still owns
the port.

## Zephyr build and flash

Track B raw Zephyr is the primary test path. Use Arduino only as a fallback
when the user asks for it or the Zephyr path is blocked.

Build raw-ranging roles with `--cmake-opt`; plain `-- -D...` was observed to
leave the cache at the default `anchor` role in this workspace.

```sh
uv run west build -b makerfabs_esp32_uwb/esp32/procpu firmware/prototypes/dw1000-raw-ranging/ --pristine always --cmake-opt=-DDW1000_RAW_ROLE=anchor
uv run west build -b makerfabs_esp32_uwb/esp32/procpu firmware/prototypes/dw1000-raw-ranging/ --pristine always --cmake-opt=-DDW1000_RAW_ROLE=tag
```

Common flash commands:

```sh
uv run west flash -r esp32 --esp-device /dev/cu.usbserial-02CC2FF0
uv run west flash -r esp32 --esp-device /dev/cu.usbserial-02CC300D
```

If flashing `/dev/cu.usbserial-02CC300D` at the default 921600 upload speed
drops or disconnects, retry that board at 115200 baud.

If a prototype uses a different app directory, replace only the app path in the
build command.

Before flashing a role image, verify the cache when there is any doubt:

```sh
rg DW1000_RAW_ROLE build/CMakeCache.txt
```

## Current Zephyr rel-nav smoke test

After flashing both boards, restart serial consoles in the `loki` tmux session.

Anchor board commands:

```text
dw1000 id
dw1000 info
range role anchor
```

Tag board commands:

```text
dw1000 id
dw1000 info
range role tag
range once
```

Expected basics:

- `DEV_ID` is `0xdeca0130`.
- Board 1 role is anchor with short address `0x0001`.
- Board 2 role is tag with short address `0x0002`.
- A successful ranging demo prints a measured distance or ToF result.

## Arduino baseline testing

Arduino is fallback-only. Prefer Track B raw Zephyr for normal firmware tests.

Arduino agents should provide upload commands or IDE steps. The orchestrator
still owns serial ports and should close `firmware_buddy` before any upload.

After upload, use either Arduino serial monitor equivalents or
`firmware_buddy serial` if the sketch uses a normal UART serial console.

## Logging discipline

Capture enough serial output for the implementing agent to reason about the
failure:

```sh
tmux capture-pane -p -t <pane-id> -S -300
```

For requested Rerun runs, capture serial data through `firmware_buddy` with
`--rerun`. Use `--rerun-save` by default for recordings that should survive the
session.

If a crash occurs, capture the full fatal exception block, including PC,
EXCCAUSE, backtrace, current thread, and the last DW1000/ranging logs before it.

## Do not commit

Do not commit or push hardware-test changes unless the user explicitly asks.
