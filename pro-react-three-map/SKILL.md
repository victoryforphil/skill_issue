---
hash: "9b8c4d2c3425b7a23d36376e793e752ba00db9b17fd0f0f2fa5224ecad85f5ff"
name: pro-react-three-map
description: Expert reference for using react-three-map with Mapbox/MapLibre, react-map-gl, and React Three Fiber. Load when implementing map scenes, geographic 3D markers, react-three-map Canvas/Coordinates, or Mapbox + R3F integration.
---

# pro-react-three-map

Use this skill when working with `react-three-map`, especially when integrating Mapbox or MapLibre maps with React Three Fiber scenes.

## Core Model

`react-three-map` bridges:

- `react-map-gl` for declarative Mapbox/MapLibre maps,
- `@react-three/fiber` for declarative Three.js scenes.

It does not replace the map provider. You still mount a `Map` from `react-map-gl`, then mount `Canvas` from `react-three-map` inside it.

## Mapbox Pattern

For Mapbox:

```tsx
import MapboxGl from "mapbox-gl"
import "mapbox-gl/dist/mapbox-gl.css"
import Map from "react-map-gl/mapbox"
import { Canvas } from "react-three-map"

MapboxGl.accessToken = mapboxToken

<Map
  antialias
  initialViewState={{ latitude, longitude, zoom, pitch }}
  mapStyle="mapbox://styles/mapbox/streets-v12"
  mapboxAccessToken={mapboxToken}
>
  <Canvas latitude={latitude} longitude={longitude}>
    {/* React Three Fiber scene */}
  </Canvas>
</Map>
```

Guidance:

- Prefer `mapboxAccessToken={token}` and only use `MapboxGl.accessToken = token` if required.
- Guard missing tokens before rendering `Map`.
- Import `mapbox-gl/dist/mapbox-gl.css` once in the app/story entry or map module.
- Use `react-map-gl/mapbox` for Mapbox, not plain `react-map-gl` when following upstream examples.

## MapLibre Pattern

For MapLibre:

```tsx
import "maplibre-gl/dist/maplibre-gl.css"
import Map from "react-map-gl/maplibre"
import { Canvas } from "react-three-map/maplibre"
```

Do not mix Mapbox imports with MapLibre imports.

## Canvas

`Canvas` is the R3F scene root anchored to map coordinates.

Important props:

- `latitude`
- `longitude`
- `altitude`, default `0`
- `frameloop`: `"always"` or `"demand"`, default `"always"`
- `overlay`: separate canvas, default `false`

R3F Canvas props ignored by `react-three-map`:

- `gl`
- `camera`
- `resize`
- `orthographic`
- `dpr`

Use `frameloop="demand"` for mostly static geographic markers.

## Coordinates

Use `Coordinates` to place children at real geographic coordinates:

```tsx
import { Coordinates } from "react-three-map"

<Coordinates latitude={point.latitude} longitude={point.longitude} altitude={point.altitude ?? 0}>
  <mesh>{/* marker */}</mesh>
</Coordinates>
```

Use this as the default for correctness across broader extents.

## NearCoordinates

`NearCoordinates` trades coordinate-scale correctness for scene-local convenience.

Use only when:

- points are local to one site/city,
- a shared scene improves performance or composition,
- scale distortion is acceptable.

Avoid it for wide-area datasets.

## Coordinate Helpers

- `coordsToVector3(point, origin)` converts coordinates to meter offsets from an origin.
- `vector3ToCoords(position, origin)` converts meter offsets back to coordinates.

Upstream caveat: precision is best at city/site scale and degrades over long distances.

## Architectural Guidance

Keep map architecture layered:

- Map shell: owns `react-map-gl` `Map`, token, style, viewport, ref, and map events.
- Three scene: owns `Canvas`, origin coordinate, `frameloop`, `overlay`, lights, and 3D-only children.
- Feature layers: convert typed domain data into `Coordinates` or `NearCoordinates`.
- DOM overlays: controls, stats, empty states, token warnings, panels. Keep these outside `Canvas`.

Do not put ordinary dashboard UI inside the R3F scene unless it needs 3D positioning or raycasting.

## Heimdall Notes

For `/Users/alex/repos/andreas/heimdall/dashboard`:

- Use Mapbox, not MapLibre, unless the user changes the decision.
- Use `VITE_MAPBOX_TOKEN`.
- Keep upload/map component contracts independent of backend `AssetRecord` until backend geo fields exist.
- Prefer Storybook fixtures and prop-driven stories for map components.
- Preserve the already-decided visual direction; this skill is about map architecture and API usage, not visual design.

## Source Reference

Cleaned local reference:

- `/Users/alex/repos/andreas/heimdall/docs/external/react-three-map.md`

Primary upstream sources:

- `https://github.com/RodrigoHamuy/react-three-map#book-examples`
- `https://rodrigohamuy.github.io/react-three-map/?story=canvas--maplibre`
- `https://raw.githubusercontent.com/RodrigoHamuy/react-three-map/main/stories/src/canvas/mapbox.stories.tsx`
- `https://raw.githubusercontent.com/RodrigoHamuy/react-three-map/main/stories/src/mapbox/story-mapbox.tsx`
- `https://raw.githubusercontent.com/RodrigoHamuy/react-three-map/main/stories/src/multi-coordinates.stories.tsx`
