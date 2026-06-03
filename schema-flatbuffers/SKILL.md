---
hash: "776760665d2890944cdd9431bcb821d5b8e97cc9acd9dc03ba12fe2d892ab133"
name: schema-flatbuffers
description: Design and evolve FlatBuffers schemas with compatibility checks, generated-code discipline, and project-neutral naming guidance.
---

# schema-flatbuffers

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `schema-flatbuffers`

# FlatBuffers Schema Maker

Create new `.fbs` files or safely evolve existing ones for the active repo.

This local skill intentionally overrides the more generic version with repo-specific references and conventions.

## Read first

- `docs/external/flatbuffers/overview.md`
- `docs/external/flatbuffers/schema-reference.md`
- `demos/demo_flatbuffers/monster.fbs`
- `demos/demo_flatbuffers/CMakeLists.txt`

If needed, confirm edge cases against `vendored/flatbuffers/docs/source/`.

## Use for

- new `.fbs` schemas
- schema updates
- `flatc` CMake integration
- thin C++ reader/writer scaffolding around generated types

## Workflow

1. Gather the data model and intended root payload.
2. Choose `table` vs `struct` carefully.
3. Author or update the schema.
4. Generate headers into a build-local `generated/` directory.
5. Verify with the narrowest useful target.
6. For published schemas, run a compatibility check.

## Schema rules

- Prefer `table` for anything that may evolve.
- Use `struct` only for stable value objects.
- Add new table fields at the end unless all fields use explicit `id`.
- Do not remove published fields; mark them `(deprecated)`.
- Avoid changing existing defaults casually.
- Avoid placeholder namespaces like `MyGame.Sample` in real repo-owned schemas.
- Include `root_type`.
- Include `file_identifier` when the payload is persisted or type-tagged.

## Local CMake pattern

```cmake
set(SCHEMA ${CMAKE_CURRENT_SOURCE_DIR}/thing.fbs)
set(GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
set(GENERATED_HEADER ${GENERATED_DIR}/thing_generated.h)

add_custom_command(
  OUTPUT ${GENERATED_HEADER}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${GENERATED_DIR}
  COMMAND $<TARGET_FILE:flatc> --cpp -o ${GENERATED_DIR} ${SCHEMA}
  DEPENDS flatc ${SCHEMA}
  COMMENT "Generating FlatBuffers headers from thing.fbs"
)
```

Then add `${GENERATED_HEADER}` to target sources and `${GENERATED_DIR}` to include directories.

## Validation

For schema evolution, prefer:

```bash
flatc --conform old.fbs new.fbs
```

## Return

- exact files created or changed
- key schema decisions
- generation and validation commands used
- any compatibility caveats

---

## Source: `asset-pipeline-flatbuffers-gltf`

# Asset Pipeline: FlatBuffers + glTF

Use this skill when working on schema-driven asset data, glTF import code, or the CMake glue around them.

## Read first

- `demos/demo_flatbuffers/CMakeLists.txt`
- `demos/demo_flatbuffers/monster.fbs`
- `demos/demo_tinygltf/CMakeLists.txt`
- `docs/external/flatbuffers/overview.md`
- `docs/external/flatbuffers/schema-reference.md`

## Working model

- Use FlatBuffers for typed, generated, versionable binary data.
- Use tinygltf to ingest glTF, then convert it into repo-owned runtime or cooked formats.
- Keep import steps deterministic and rebuildable.
- Keep generated code in the build tree unless there is a clear reason not to.

## Preferred workflow

1. Define or update schema shape first.
2. Generate headers with `flatc` in CMake.
3. Add a thin reader, writer, or conversion layer.
4. Keep glTF parsing separate from runtime-owned data structures.
5. Verify with a targeted build.

## Rules

- Prefer repo-owned cooked/runtime formats over leaking third-party types across the engine.
- Keep schema evolution conservative.
- Do not mix parsing, validation, conversion, and runtime ownership into one large function.
- Treat asset import code as pipeline code: explicit, inspectable, and boring.

## Ask first before

- making incompatible persisted-format changes
- committing generated FlatBuffers headers
- exposing glTF details through stable public project APIs
- introducing a large asset database or hot-reload framework
