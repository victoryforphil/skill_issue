---
hash: "4c7a169d4c1516ed2576dba9fa6cf0eee0f49cda7707a133f110eda7a98da779"
name: flatbuffers-schema-maker
description: Use when creating or evolving FlatBuffers schemas. Follows standard schema design, compatiblity rules, and CMake generation patterns.
---

# FlatBuffers Schema Maker

Create new `.fbs` files or safely evolve existing ones for this repo.

## Best Practices

### 1. Table vs Struct
- **Prefer `table`** for any data model that may change, evolve, or add fields over time.
- **Use `struct`** only for stable, fixed-size value types whose layout is guaranteed never to change (e.g., a 3D `Vector3` or a `Color` structure).

### 2. Schema Evolution & Compatibility
- **Add fields at the end:** Always add new fields to the end of a table.
- **Never remove fields:** Do not delete fields from a published schema. Instead, mark them as `(deprecated)`.
- **IDs:** If fields have explicit `id` attributes, ensure new fields are assigned the next sequential integer.
- **Namespaces:** Use clean, professional namespaces. Avoid placeholders like `MyGame.Sample` in real production schemas.
- **Identifiers:** Include `root_type` and a unique 4-character `file_identifier` if the payload is persisted, transmitted over the wire, or type-tagged.

---

## Universal CMake Integration

When integrating FlatBuffers codegen into a CMake build tree:

```cmake
set(SCHEMA ${CMAKE_CURRENT_SOURCE_DIR}/protocol.fbs)
set(GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
set(GENERATED_HEADER ${GENERATED_DIR}/protocol_generated.h)

add_custom_command(
  OUTPUT ${GENERATED_HEADER}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${GENERATED_DIR}
  COMMAND $<TARGET_FILE:flatc> --cpp -o ${GENERATED_DIR} ${SCHEMA}
  DEPENDS flatc ${SCHEMA}
  COMMENT "Generating FlatBuffers headers from protocol.fbs"
)
```

## Validation

Verify schema compatibility when modifying existing schemas:

```bash
flatc --conform old.fbs new.fbs
```
