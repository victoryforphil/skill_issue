---
name: style-core
description: Apply generic smallest-correct-change, one-clear-path, focused-file, and maintainability style rules for implementation, refactor, docs, prompts, and review tasks.
---

# style-core

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `style-core`

# Style Core

Read active repo `STYLE.md`/`AGENTS.md` first.

Use this skill as the repo-wide style lens for code, CMake, docs, prompts, and review.

## Main rules

- Make the smallest correct change.
- Prefer one clear path over multiple competing flows.
- Reduce maintenance exposure when it improves clarity.
- Prefer focused files and readable code over clever abstractions.
- Keep generated outputs in the build tree.
- Keep docs and prompts short and scannable.

## Apply with narrower skills

Use this skill first, then add a narrower skill when relevant:

- C++: `style-cpp`
- CMake: `cpp-cmake`
- Review: `review-cpp-engine`
- Docs/prompts/skills: `style-docs-writing`

## Update rule

If the user gives repeated style feedback, add or refine a short rule in `STYLE.md` instead of scattering the preference across many prompts or files.
