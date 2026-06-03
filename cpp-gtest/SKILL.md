---
hash: "48194146fbc2b520063360a6f0042d66a3d41529d0ad8528af3ba457b91cd78b"
name: cpp-gtest
description: Discover, build, and run GoogleTest/CTest tests with focused filters, direct executable runs, and compact verification reporting.
---

# cpp-gtest

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `gtest-runner`

# GTEST Runner Skill

Use to run unit tests in this project.

## Commands

```bash
# Run all tests via mise
mise run test

# Run matching tests via mise
mise run test -- -R project_asset

# Run all tests via ctest directly
ctest --test-dir build --output-on-failure

# Build and run specific test
cmake --build build --target test_project_asset
./build/engine/project_asset/tests/test_project_asset
```

## Test locations

- Unit tests: `engine/project_asset/tests/`
- Test executable: `build/engine/project_asset/tests/test_project_asset`

## Adding new tests

1. Add test .cpp file to `engine/project_asset/tests/`
2. Add to CMakeLists.txt in that directory
3. Tests are auto-registered via `enable_testing()` in root CMakeLists.txt

## Notes

- GTEST is vendored in `vendored/googletest/`
- `enable_testing()` must be in root CMakeLists.txt before add_subdirectory for tests
- Use agent-lite for simple test fixes/updates, agent-med+ for debugging test failures
