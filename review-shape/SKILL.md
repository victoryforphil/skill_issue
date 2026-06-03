---
hash: "a8700d3121774c6ba3a2b12b66d0ca1204f3bf21dad34a8087f0c36f2e3b7e02"
name: review-shape
description: Review file and function shape for scanability, size, boundaries, and one-clear-path structure.
---

# review-shape

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `review-file-shape`

# Review: File Shape

Use this when checking file layout and scan cost.

## Rule

Prefer one primary type or main responsibility per file.
Tiny closely related helper or config types may stay with it.
If a file stops being easy to scan, split by concern.

## Check

- one primary type or responsibility per file, or close to it
- helper/config types are tiny and tightly coupled
- public API types stay in focused headers when that improves browsing
- file growth did not create a kitchen-sink module

## Flag

- multiple peer public types in one file without a strong reason
- files that mix unrelated responsibilities
- large helper/config sidecars that should now be separate
- new growth that makes scanning materially harder

## Output

Return only concrete findings with file paths and evidence, or `looks good`.

---

## Source: `review-function-size`

# Review: Function Size

Use this when checking function and method shape.

## Rule

Prefer short functions with one clear job.
Split by phase when that improves readability without hiding the flow.

## Check

- functions stay easy to scan in one pass
- parse, validate, transform, render, and I/O phases are not unnecessarily mixed
- helper extraction would remove repetition or mental load

## Flag

- long functions with multiple jobs
- nested control flow that hides the main path
- repeated setup or cleanup that wants a helper
- handlers that mix orchestration with detailed leaf logic

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
