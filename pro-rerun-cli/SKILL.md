---
name: pro-rerun-cli
description: >
  Expert knowledge of the Rerun CLI (`rerun` binary). Load when working with the
  Rerun command-line tool — covers all commands, subcommands, flags, and common
  workflows for the viewer, gRPC server, RRD/MCAP file manipulation, and auth.
---

# Rerun CLI — Expert Reference

> The `rerun` binary: spawn viewers, host gRPC servers, manipulate .rrd/.rbl/.mcap files, and manage auth.

**Docs:** https://rerun.io/docs/reference/cli
**Version captured:** 0.33.0

---

## Overview

The `rerun` CLI bundles multiple tools: a native/web viewer, an OSS gRPC catalog server, RRD/MCAP file manipulation utilities, and auth management. It can be installed via `pip install rerun-sdk`, downloaded from GitHub releases, or built from source with `cargo install rerun-cli --locked`.

---

## Top-level Usage

```
rerun [OPTIONS] [URL_OR_PATHS]… [COMMAND]
```

**URL_OR_PATHS** accepts any combination of:
- A gRPC URL to a Rerun server
- A path to a `.rrd` recording or `.rbl` blueprint
- An HTTP(S) URL to an `.rrd`/`.rbl` file
- A path to an image, mesh, or other loadable file

If no arguments are given, a server is hosted for SDK connections.

---

## Global Options

| Flag | Default | Purpose |
|------|---------|---------|
| `--port <PORT>` | `9876` | gRPC port for SDK connections. Use `auto` for free port. |
| `--new` | `false` | Alias for `--port auto`. Always start a new viewer. |
| `--bind <BIND>` | `0.0.0.0` | Bind address IP. `::` listens on all interfaces. |
| `--serve-web` | `false` | Host web-viewer over HTTP + gRPC server. |
| `--serve-grpc` | `false` | Host a gRPC server only (proxy mode). |
| `--connect <CONNECT>` | — | Connect to existing gRPC server (`rerun+http://…/proxy`). |
| `--memory-limit <LIMIT>` | — | Max viewer memory (e.g. `16GB`, `50%`). Drops oldest data. |
| `--server-memory-limit <LIMIT>` | `1GiB` | Max gRPC server memory. |
| `--newest-first` | `false` | Play back most recent data first for new clients. |
| `--save <PATH>` | — | Stream incoming logs to an `.rrd` file. |
| `--follow` | `false` | Tail `.rrd` files, wait for new data after EOF. |
| `--web-viewer` | `false` | Start viewer in browser (implies `--serve-web`). |
| `--web-viewer-port` | `9090` | HTTP port for web viewer. |
| `--headless` | `false` | Run viewer headless (no OS window, offscreen harness). |
| `--screenshot-to <PATH>` | — | Take screenshot and quit. Use with `--window-size`. |
| `--window-size <WxH>` | — | Set screen resolution (e.g. `1920x1080`). |
| `--renderer <BACKEND>` | — | Override graphics backend: `vulkan`, `gl`, `metal`, `webgpu`, `webgl`. |
| `--video-decoder <MODE>` | `auto` | Video decode: `auto`, `prefer_software`, `prefer_hardware`. |
| `--persist-state` | `true` | Persist viewer state to disk. |
| `--hide-welcome-screen` | `false` | Hide the welcome screen. |
| `--detach-process` | `false` | Detach viewer from application process. |
| `--expect-data-soon` | `false` | Hint that data is arriving (fades in welcome screen). |
| `--cors-allow-origin <PATTERN>` | — | Additional CORS origins (glob matching). Repeatable. |
| `-j, --threads <N>` | `-2` | Compute threads. 0 = all cores, negative = cores - N. |
| `--profile` | `false` | Start with puffin profiler. |
| `--test-receive` | `false` | Ingest data and quit on goodbye message (testing). |
| `--version` | `false` | Print version and quit. |

---

## Subcommands

### `rerun analytics`

Configure analytics behavior.

| Subcommand | Purpose |
|------------|---------|
| `details` | Print extra analytics info |
| `clear` | Delete all analytics data |
| `email <EMAIL>` | Associate email with current user |
| `enable` | Enable analytics |
| `disable` | Disable analytics |
| `config` | Print current configuration |

### `rerun auth`

Authentication with Rerun Hub (redap).

| Subcommand | Purpose |
|------------|---------|
| `login` | Log into Rerun Hub (opens browser) |
| `logout` | Clear stored credentials |
| `token` | Retrieve stored access token |
| `generate-token` | Generate fresh access token |

**`auth login` options:** `--no-open-browser`, `--force`
**`auth generate-token` options:** `--server <ORIGIN>`, `--expiration <DURATION>`, `--permission {read,read-write}`

### `rerun download`

Download recordings and save as `.rrd` files.

```
rerun download [OPTIONS] <URLS>…
```

Options: `-o, --output-dir <DIR>` (defaults to CWD).

### `rerun mcap`

Manipulate `.mcap` files.

| Subcommand | Purpose |
|------------|---------|
| `convert` | Convert `.mcap` to `.rrd` |
| `info` | Print timeline/sortedness diagnostics |

**`mcap convert` key options:**
- `-o, --output <PATH>` — output path (stdout if omitted)
- `--application-id <ID>` — set application id
- `-d, --decoder <DECODERS>` — decoders to apply
- `--recording-id <ID>` — set recording id
- `--timestamp-offset-ns <NS>` — offset for timestamp timelines
- `--timeline-type {timestamp,duration}` — timeline type (default: `timestamp`)
- `-y, --include-topic-regex <REGEX>` — include topics (RE2, repeatable)
- `-n, --exclude-topic-regex <REGEX>` — exclude topics (RE2, repeatable)
- `--disable-raw-fallback` — disable raw decoder fallback

**`mcap info` options:** `--full` — run full decoder pipeline

### `rerun rrd`

Manipulate `.rrd` and `.rbl` files.

| Subcommand | Purpose |
|------------|---------|
| `compare` | Compare 2 `.rrd` files (exit code match) |
| `filter` | Filter out data, write to stdout |
| `merge` | Merge multiple files, write to stdout |
| `migrate` | Migrate to newest RRD version |
| `optimize` | Compact chunks, write to stdout |
| `print` | Print file contents |
| `route` | Manipulate metadata without decoding |
| `split` | Split recording on a timeline |
| `stats` | Compute statistics |
| `verify` | Verify file can be loaded |

**`rrd compare` options:** `--unordered`, `--full-dump`, `--ignore-chunks-without-components`

**`rrd filter` options:** `-o`, `--drop-timeline <NAMES>`, `--drop-entity <PATHS>`, `--continue-on-error`

**`rrd merge` options:** `-o`, `--continue-on-error`
> Auto-migrates to latest RRD protocol if needed.

**`rrd optimize` options:**
- `-o, --output` — output path (stdout if omitted)
- `--profile {object-store}` — optimization profile
- `--max-size <SIZE>` — chunk size threshold (e.g. `2MiB`)
- `--max-rows <N>` — row threshold
- `--max-rows-if-unsorted <N>` — row threshold for unsorted chunks
- `--num-pass <N>` — extra compaction passes (default: 50)
- `--no-rebatch-videos` — disable GoP rebatching
- `--fix-keyframe` — re-derive keyframe labels
- `--split-size-ratio <RATIO>` — split thick/thin archetype columns
- `--continue-on-error`

> Supports **directory mirror mode**: pass a directory as input, set `-o` as output root, structure is preserved.

**`rrd optimize` examples:**
```bash
rerun rrd optimize my.rrd -o my-compacted.rrd
rerun rrd optimize --max-size 2MiB /my/recordings/*.rrd -o output.rrd
cat my.rrd | rerun rrd optimize --max-rows 4096 --max-size 2MiB > output.rrd
rerun rrd optimize --max-size 2MiB /my/recordings -o /my/recordings-compacted
```

**`rrd print` options:** `-v, --verbose` (repeatable for more detail)

### `rerun server`

In-memory Rerun data server (OSS catalog server).

---

## Common Workflows

### Stream to viewer
```bash
# Start viewer, SDK connects automatically
rerun
# Or: Python
rr.spawn()
```

### View a recording
```bash
rerun path/to/recording.rrd
```

### Host web viewer
```bash
rerun --serve-web
# Or: rerun --web-viewer
```

### Save logs to file
```bash
rerun --save output.rrd
# Or from Python: rr.save("output.rrd")
```

### Optimize recordings
```bash
rerun rrd optimize input.rrd -o optimized.rrd
```

### Merge recordings
```bash
rerun rrd merge /path/to/recordings/*.rrd > merged.rrd
```

### Convert MCAP to RRD
```bash
rerun mcap convert input.mcap -o output.rrd
```

### Headless screenshot
```bash
rerun recording.rrd --headless --screenshot-to shot.png --window-size 1920x1080
```

---

## Gotchas & Tips

- `--port auto` or `--new` avoids "port already in use" errors when spawning multiple viewers.
- `--connect` does NOT start a new server — use when you already have a viewer running.
- `rrd optimize` auto-migrates data to latest RRD protocol version.
- Web Viewer is 32-bit Wasm, limited to ~2 GiB memory. Use native viewer for large datasets.
- `--headless` keeps the gRPC server running so SDK clients can still log data and request screenshots.
- `RERUN_PANIC_ON_WARN=1` env var combined with `--test-receive` is useful for CI testing.
- `--follow` is essential for live-streaming from a writer process to the viewer.
- Environment variables `RERUN_CHUNK_MAX_ROWS`, `RERUN_CHUNK_MAX_ROWS_IF_UNSORTED`, `RERUN_CHUNK_MAX_BYTES` control `rrd optimize` defaults.

---

## Useful Links

- [CLI reference](https://rerun.io/docs/reference/cli)
- [GitHub releases](https://github.com/rerun-io/rerun/releases)
- [Python SDK install](https://rerun.io/docs/getting-started/install-rerun/python)
- [Cargo install](https://github.com/rerun-io/rerun) — `cargo install rerun-cli --locked`
