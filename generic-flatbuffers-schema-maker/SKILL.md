---
name: generic-flatbuffers-schema-maker
description: Generic FlatBuffers schema skill for projects without a repo-specific FlatBuffers schema skill.
---

# generic-flatbuffers-schema-maker

Create new FlatBuffers schema files and wire them into C++/CMake projects safely.

## When to use
Use this skill when the user asks to:
- create a new `.fbs` schema,
- evolve an existing schema,
- generate `flatc` outputs and CMake integration,
- scaffold code that reads/writes generated FlatBuffers types.

## Canonical references
When available in the active repo, use these first:
- `<repo>/docs/external/flatbuffers/overview.md`
- `<repo>/docs/external/flatbuffers/schema-reference.md`

Then verify with upstream docs as needed:
- https://flatbuffers.dev/schema/
- https://flatbuffers.dev/grammar/
- https://flatbuffers.dev/evolution/
- https://flatbuffers.dev/flatc/

## Workflow

1. **Gather requirements**
   - Data model entities and relationships
   - Namespace
   - Root table
   - File identifier (if serialized to disk/network as a typed payload)
   - Target language(s) and output path

2. **Design schema with compatibility in mind**
   - Prefer `table` for evolvable entities.
   - Use `struct` only for fixed, stable value objects.
   - Add new table fields only at the end (unless all fields use explicit `id`).
   - Never physically remove published fields; mark old ones `(deprecated)`.
   - Avoid default-value changes for existing fields.

3. **Author `.fbs` file**
   - Follow consistent formatting:
     - types: `UpperCamelCase`
     - fields: `snake_case`
   - Include `root_type`.
   - Include `file_identifier` when appropriate.

4. **Integrate generation/build**
   - Use `flatc --cpp` in build tooling (typically CMake custom command).
   - Generate headers into a build/generated dir.
   - Add include dirs for generated headers.
   - Add schema and generated headers as dependencies/sources where needed.

5. **Add usage scaffold (optional)**
   - Reader: verifier + `Get<RootType>()`
   - Writer: `FlatBufferBuilder` + `Create...` / `<Table>Builder`

6. **Validate**
   - Build project.
   - If evolving an existing schema, run:
     - `flatc --conform old.fbs new.fbs`

## Output contract
When implementing, return:
- Files created/updated (exact paths)
- Key schema decisions (table vs struct, defaults, identifiers)
- Commands used for generation/validation
- Any compatibility caveats

## Practical template

```fbs
namespace MyGame.Feature;

enum Kind : byte {
  Unknown = 0,
  Example = 1
}

struct Vec3 {
  x:float;
  y:float;
  z:float;
}

table Item {
  id:uint;
  name:string;
}

table Root {
  kind:Kind = Unknown;
  position:Vec3;
  items:[Item];
}

root_type Root;
file_identifier "ABCD";
```

## CMake snippet template

```cmake
set(SCHEMA ${CMAKE_CURRENT_SOURCE_DIR}/feature.fbs)
set(GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
set(GENERATED_HEADER ${GENERATED_DIR}/feature_generated.h)

add_custom_command(
  OUTPUT ${GENERATED_HEADER}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${GENERATED_DIR}
  COMMAND $<TARGET_FILE:flatc> --cpp -o ${GENERATED_DIR} ${SCHEMA}
  DEPENDS flatc ${SCHEMA}
  COMMENT "Generating FlatBuffers headers from feature.fbs"
)
```
