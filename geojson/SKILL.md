---
hash: "819cfc9fc16028df3c83718794df8f20da402aab3bd04fb19fdefcc906445f3b"
name: geojson
description: >
  Expert knowledge of the geojson Rust crate (0.24.2). Load when working with geojson — covers key API, types, traits, patterns, and navigation tips scraped from docs.rs.
---

# `geojson` — Expert Reference

> Read and write GeoJSON vector geographic data

**Docs:** https://docs.rs/geojson/latest/geojson/  
**Version captured:** 0.24.2

---

## Overview

The `geojson` crate helps you read and write GeoJSON — a format for encoding geographic data structures. This crate is structured around the GeoJSON spec (IETF RFC 7946), with corresponding struct and type definitions for all GeoJSON elements.

There are two primary ways to use this crate:

1. **Direct GeoJSON types** — Use the crate's structs (`Feature`, `FeatureCollection`, `Geometry`, `Value`) for full control and type safety
2. **Serde integration** — Use your own types with `geojson::ser` and `geojson::de` modules for custom serialization

The crate requires the `geo-types` feature for geo-types integration (enabled by default).

---

## Key Types

| Type | Kind | Purpose |
|------|------|---------|
| `Feature` | struct | Represents a GeoJSON Feature with geometry and properties |
| `FeatureCollection` | struct | Represents a collection of Features |
| `Geometry` | struct | Represents geometry objects (Point, LineString, Polygon, etc.) |
| `Value` | enum | The underlying value for a Geometry (Point, LineString, Polygon, etc.) |
| `Bbox` | type alias | Bounding boxes (Vec<f64>) |
| `JsonObject` | type alias | Map<String, JsonValue> for properties |
| `JsonValue` | type alias | serde_json::Value |
| `Position` | type alias | Vec<f64> for coordinates |
| `PointType` | type alias | Alias for Position |
| `LineStringType` | type alias | Vec<Position> |
| `PolygonType` | type alias | Vec<Vec<Position>> |
| `Error` | enum | Error type for all GeoJSON operations |
| `Result<T>` | type alias | Result type alias using Error |

---

## Key Traits

| Trait | Implement to… | Derivable? |
|-------|--------------|-----------|
| `From<Geometry>` for Feature | Convert geometry to a Feature | Manual |
| `From<FeatureCollection>` for GeoJson | Convert collection to top-level GeoJson | Manual |
| `TryFrom<GeoJson>` for Feature | Parse top-level GeoJson to Feature | Manual |
| `FromIterator<Feature>` for FeatureCollection | Collect features from iterator | Manual |
| `IntoIterator` for FeatureCollection | Iterate over features | Manual |
| `From<&'a Geometry<T>> for Value` | Convert geometry to Value | Manual |
| `TryFrom<&Value> for Geometry<T>` | Parse Value to geometry | Manual |
| `From<geo_types::Geometry<T>> for Value` | Convert geo-types geometry to Value | Manual |
| `TryFrom<GeoJson>` for geo_types::Geometry<T>` | Parse GeoJson to geo-types geometry | Manual |

---

## Core Patterns

### Parsing GeoJSON
```rust
use geojson::{GeoJson, Feature, Geometry, Value};
use std::convert::TryFrom;

let geojson_str = r#"
{
  "type": "Feature",
  "properties": { "food": "donuts" },
  "geometry": {
    "type": "Point",
    "coordinates": [ -118.2836, 34.0956 ]
  }
}
"#;

let geojson: GeoJson = geojson_str.parse::<GeoJson>().unwrap();
let feature: Feature = Feature::try_from(geojson).unwrap();

// Read property data
assert_eq!("donuts", feature.property("food").unwrap());

// Read geometry data
let geometry: Geometry = feature.geometry.unwrap();
if let Value::Point(coords) = geometry.value {
    assert_eq!(coords, vec![-118.2836, 34.0956]);
}
```

### Creating a Feature
```rust
use geojson::{Feature, Geometry, Value};

let feature = Feature {
    bbox: None,
    geometry: Some(Geometry::new(Value::Point(vec![-118.2836, 34.0956]))),
    id: None,
    properties: Some(serde_json::json!({"name": "Test Feature"}).as_object().cloned()),
    foreign_members: None,
};
```

### Serializing to GeoJSON
```rust
use geojson::{GeoJson, Geometry, Value};

let geometry = Geometry::new(Value::Point(vec![-120.66029, 35.2812]));
let geojson = GeoJson::Feature(Feature {
    bbox: None,
    geometry: Some(geometry),
    id: None,
    properties: Some(serde_json::json!({"name": "Firestone Grill"}).as_object().cloned()),
    foreign_members: None,
});

let geojson_string = geojson.to_string();
```

### Converting geojson to geo-types
```rust
use geojson::{GeoJson, Geometry, Value};
use geo_types::Geometry;
use std::convert::TryFrom;

let geojson_str = r#"
{
 "type": "Feature",
 "properties": {},
 "geometry": {
   "type": "Point",
   "coordinates": [ -0.13583511114120483, 51.5218870403801 ]
 }
}
"#;

let geojson = GeoJson::from_str(geojson_str).unwrap();
let geom = Geometry::<f64>::try_from(geojson).unwrap();
```

### Processing Geometry Collections
```rust
use geojson::{GeoJson, Geometry, Value};

fn process_geojson(gj: &GeoJson) {
    match *gj {
        GeoJson::FeatureCollection(ref ctn) => {
            for feature in &ctn.features {
                if let Some(ref geom) = feature.geometry {
                    process_geometry(geom)
                }
            }
        }
        GeoJson::Feature(ref feature) => {
            if let Some(ref geom) = feature.geometry {
                process_geometry(geom)
            }
        }
        GeoJson::Geometry(ref geometry) => process_geometry(geometry),
    }
}

fn process_geometry(geom: &Geometry) {
    match geom.value {
        Value::Polygon(_) => println!("Matched a Polygon"),
        Value::MultiPolygon(_) => println!("Matched a MultiPolygon"),
        Value::GeometryCollection(ref gc) => {
            println!("Matched a GeometryCollection");
            // GeometryCollections can nest — process each element
            for geometry in gc {
                process_geometry(geometry)
            }
        }
        _ => println!("Matched some other geometry"),
    }
}
```

### Using Custom Types with Serde
```rust
use serde::{Serialize, Deserialize};

#[derive(serde::Serialize, serde::Deserialize)]
struct MyStruct {
    #[serde(serialize_with = "serialize_geometry", deserialize_with = "deserialize_geometry")]
    geometry: geo_types::Point<f64>,
    name: String,
    count: u64,
}
```

---

## Module Map

| Module path | Contains |
|-------------|---------|
| `geojson::de` | Deserialization helpers for custom types |
| `geojson::ser` | Serialization helpers for custom types |
| `geojson::errors` | Error types (Error, Result) |
| `geojson::feature` | Feature-related types and implementations |
| `geojson::geometry` | Geometry types and implementations |
| `geojson::geojson` | GeoJson enum and top-level types |
| `geojson::util` | Utility functions |

---

## Feature Flags

| Flag | Enables | Default? |
|------|---------|---------|
| `geo-types` | geo-types integration for converting between geojson and geo-types geometries | yes |

---

## Gotchas & Tips

- **GeometryCollection conversion**: When converting a GeometryCollection, decide if you want a single Feature with a GeometryCollection geometry, or a FeatureCollection with each element converted to its own Feature
- **Properties field**: The `properties` field is always included when serializing, even if empty
- **Permissive parsing**: The crate permissively parses features missing the `properties` key
- **Round-tripping**: Round-tripping with intermediate processing using geo-types may not produce identical output, as outer Polygon rings are automatically closed
- **Polygon orientation**: The crate may re-orient Polygon rings when serializing
- **geo-types conversion**: Conversions between geojson and geo-types are fallible (use `TryFrom`/`TryInto`)
- **Feature properties**: Properties hold `serde_json::Value`, so use `JsonObject` for typed access

---

## Useful Links

- [Crate root](https://docs.rs/geojson/latest/geojson/)
- [GitHub / source](https://github.com/georust/geojson)
- [Changelog](https://github.com/georust/geojson/blob/master/CHANGELOG.md)
- [GeoJSON Specification](https://tools.ietf.org/html/rfc7946)