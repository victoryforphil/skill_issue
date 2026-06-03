---
name: pro-rerun
description: >
  Expert knowledge of the Rerun visualization SDK and platform (v0.33.0). Load
  when working with Rerun — covers architecture, data model (ECS), archetypes,
  SDK operating modes, blueprints, timelines, the viewer, and CLI usage.
---

# Rerun — Expert Reference

> The data layer for Physical AI: log, visualize, query, and transform multimodal data.

**Docs:** https://rerun.io/docs
**Version captured:** 0.33.0
**GitHub:** https://github.com/rerun-io/rerun

---

## Overview

Rerun is an SDK + viewer for visualizing multimodal data over time. It uses an Entity Component System (ECS) data model, supports Python/Rust/C++ SDKs, and provides a native desktop viewer, web viewer, and gRPC-based streaming architecture. Data is organized into recordings, logged via archetypes (bundles of components), and visualized through configurable views and blueprints.

---

## Architecture

| Component | Purpose |
|-----------|---------|
| **Logging SDK** | Runs in your app, logs data via archetypes (Python/Rust/C++) |
| **Viewer** | Native desktop or web app that visualizes data |
| **Chunk Store** | In-memory database inside the viewer |
| **gRPC endpoint** | Accepts streamed data from SDKs |
| **Catalog server** | Persistent storage/indexing via redap protocol (`rerun server` or Rerun Hub) |
| **Catalog SDK** | Python library (`rerun.catalog`) for querying catalog data |

---

## Data Model (ECS)

- **Entities** — "things" you log, identified by entity paths (strings). Like folders.
- **Components** — data associated with entities (position, color, pixels, etc.). Like files.
- **Archetypes** — coherent bundles of components for common types (Points3D, Image, Transform3D, etc.). High-level helpers.
- **Datatypes** — fundamental data structures used by components when primitives aren't enough.

```python
rr.log("my_point", rr.Points2D([32.7, 45.9], colors=[255, 0, 0]))
# Creates entity "my_point" with Points2D:positions and Points2D:colors components
```

---

## Core Archetypes

### Spatial 2D
| Archetype | Purpose |
|-----------|---------|
| `Points2D` | 2D point cloud |
| `Boxes2D` | 2D bounding boxes |
| `LineStrips2D` | 2D line strips |
| `Arrows2D` | 2D arrows |
| `Ellipses2D` | 2D ellipses |

### Spatial 3D
| Archetype | Purpose |
|-----------|---------|
| `Points3D` | 3D point cloud |
| `Boxes3D` | 3D bounding boxes |
| `Mesh3D` | 3D triangle mesh |
| `Asset3D` | Prepacked 3D asset (.gltf, .glb, .obj, .stl) |
| `LineStrips3D` | 3D line strips |
| `Arrows3D` | 3D arrows |
| `Capsules3D` | 3D capsules |
| `Cylinders3D` | 3D cylinders |
| `Ellipsoids3D` | 3D ellipsoids/spheres |

### Images & Tensors
| Archetype | Purpose |
|-----------|---------|
| `Image` | Monochrome or color image |
| `DepthImage` | Depth image from camera |
| `EncodedImage` | JPEG/PNG encoded image |
| `SegmentationImage` | Integer class-ID image |
| `Tensor` | N-dimensional array |

### Plotting
| Archetype | Purpose |
|-----------|---------|
| `Scalars` | Double-precision scalar values |
| `SeriesLines` | Line series style |
| `SeriesPoints` | Scatter plot style |
| `BarChart` | Bar chart |
| `StateChange` | State transition |
| `StateConfiguration` | State style/mapping |

### Text
| Archetype | Purpose |
|-----------|---------|
| `TextDocument` | Standalone text display |
| `TextLog` | Log entry with level |

### Transforms
| Archetype | Purpose |
|-----------|---------|
| `Transform3D` | Pose between 3D spaces |
| `Pinhole` | Camera intrinsics |
| `ViewCoordinates` | Coordinate system interpretation |
| `CoordinateFrame` | Coordinate frame specification |
| `TransformAxes3D` | Visual representation of Transform3D |

### Video
| Archetype | Purpose |
|-----------|---------|
| `AssetVideo` | Video binary |
| `VideoStream` | Raw video chunks |
| `VideoFrameReference` | Reference to single video frame |

### Other
| Archetype | Purpose |
|-----------|---------|
| `AnnotationContext` | Display annotations |
| `Clear` | Empty all components of entity |
| `RecordingInfo` | Recording properties |
| `GraphNodes` / `GraphEdges` | Graph data |
| `GeoPoints` / `GeoLineStrings` | Geospatial (EPSG:4326) |
| `McapChannel` / `McapMessage` / `McapSchema` / `McapStatistics` | MCAP support |

---

## SDK Operating Modes

| Mode | Function | Description |
|------|----------|-------------|
| `spawn` | `rr.spawn()` | Start viewer in external process, stream via gRPC (default) |
| `connect_grpc` | `rr.connect_grpc()` | Connect to existing viewer via gRPC |
| `serve_grpc` | `rr.serve_grpc()` | Start gRPC server in your process (proxy mode) |
| `save` | `rr.save(path)` | Stream to `.rrd` file on disk |
| `stdout` | `rr.stdout()` | Stream to stdout, load via stdin |
| `set_sinks` | `rr.set_sinks(...)` | Log to multiple sinks concurrently |

```python
# Multiple sinks: save to file AND stream to viewer
rr.set_sinks(rr.GrpcSink(), rr.FileSink("data.rrd"))
```

> Modes override each other. Use `set_sinks()` for concurrent sinks.

---

## Timelines & Events

Every log call is associated with timelines. Two are automatic:
- `log_tick` — sequence timeline (log call counter)
- `log_time` — temporal timeline (wall clock)

Custom timelines via `rr.set_time()`:

```python
rr.set_time("frame_idx", sequence=42)
rr.set_time("sensor_time", timestamp=1_741_017_564)
rr.log("sensor/points", rr.Points3D(frame.points))
```

**Index types** (all encoded as `i64`):
- Sequential: `sequence=N`
- Timestamp: `timestamp=<datetime or ns since epoch>`
- Timedelta: `duration=<seconds>`

**Static data:** `rr.log("path", data, static=True)` — belongs to all timelines, shadows temporal data.

---

## Blueprints

Blueprints control HOW data is displayed (vs recordings which provide WHAT).

- **Application ID** binds blueprints to recordings — all recordings sharing an ID use the same blueprint
- Blueprint data uses the same ECS model as recordings but with blueprint-specific archetypes

**Three ways to work with blueprints:**

1. **Interactively** — drag/drop, split views in the Viewer UI
2. **Save/load files** — `.rbl` files, portable and version-controllable
3. **Programmatically** — Python `rerun.blueprint` API

```python
import rerun.blueprint as rrb

blueprint = rrb.Grid(
    rrb.Spatial3DView(name="3D", origin="/world"),
    rrb.TimeSeriesView(name="Sensors", origin="/sensors"),
    rrb.TextLogView(name="Logs", origin="/diagnostics"),
)
rr.send_blueprint(blueprint, make_active=True)
```

**Reset behavior:**
- "Reset to heuristic" — auto-generates layout from data
- "Reset to default" — restores programmatic or saved `.rbl` blueprint

---

## Viewer

The Viewer has four main panels:
- **Blueprint Panel** — manage views and layout
- **Selection Panel** — inspect entity properties
- **Time Panel** — timeline navigation
- **Viewport** — the actual visualization area

**View types:** Spatial2D, Spatial3D, TimeSeries, TextLog, BarChart, Tensor, Map, Graph, Dataframe, StateTimeline, TextDocument

---

## Key Concepts

### Entity Path Hierarchy
Entity paths form a tree: `/robot/arm/joint1`. The Viewer inherits properties down the hierarchy.

### Transforms & Coordinate Frames
`Transform3D` defines the relationship between parent and child coordinate frames. `Pinhole` defines camera intrinsics. `ViewCoordinates` specifies axis convention (e.g. RDF = right-down-forward).

### Chunks
Internal storage mechanism. Data is stored as chunks (columnar Arrow format). Compaction merges small chunks for efficiency. Controlled via `RERUN_CHUNK_MAX_ROWS`, `RERUN_CHUNK_MAX_BYTES` env vars.

### RRD Format
Native file format (`.rrd`). Backward-compatible across adjacent minor versions (0.24 opens 0.23 RRDs). Use `rerun rrd migrate` for older files.

### Importers
Rerun can load many file formats: images, meshes (.gltf, .glb, .obj, .stl), videos, MCAP, point clouds, and more. See the importers overview.

### MCAP Support
Rerun can convert and visualize MCAP files (robotics data format). Use `rerun mcap convert` CLI or log MCAP archetypes directly.

### Sinks
Where logged data goes. Modes (`spawn`, `connect_grpc`, `save`, etc.) are sinks. Use `set_sinks()` for multiple concurrent destinations.

---

## Installation

```bash
# Python
pip install rerun-sdk

# Rust
cargo install rerun-cli --locked

# Or download from GitHub releases
```

---

## Gotchas & Tips

- Web Viewer is 32-bit Wasm, ~2 GiB memory limit. Use native viewer for large datasets.
- `rr.spawn()` connects to existing viewer if one is already running (doesn't double-spawn).
- Use `rr.set_time()` before `rr.log()` to associate data with custom timelines.
- `static=True` data shadows temporal data of the same type on the same entity.
- Blueprint overrides are as powerful as logged data — they use the same ECS model.
- `rerun rrd optimize` auto-migrates to latest protocol version.
- Use `send_columns()` for efficient batch logging of temporal data.
- The `rerun` CLI bundles viewer, server, and file tools — no separate installs needed.

---

## Useful Links

- [Docs home](https://rerun.io/docs)
- [Concepts](https://rerun.io/docs/concepts/how-does-rerun-work)
- [Types reference](https://rerun.io/docs/reference/types)
- [Python API](https://ref.rerun.io/docs/python)
- [Rust API](https://docs.rs/rerun/)
- [C++ API](https://ref.rerun.io/docs/cpp)
- [Examples](https://rerun.io/examples)
- [GitHub](https://github.com/rerun-io/rerun)
- [Discord](https://discord.gg/PXtCgFBSmH)
