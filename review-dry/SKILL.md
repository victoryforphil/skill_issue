---
name: review-dry
description: Review for harmful duplication, copy-pasted logic, unnecessary wrappers, and chances to remove repeated maintenance paths.
---

# review-dry

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `review-dry`

# Review: DRY

Use this when checking duplication and single-source-of-truth quality.

## Rule

Prefer one source of truth for shared behavior, rules, and transformations.
Do not force abstraction when tiny local duplication is clearer.

## Check

- repeated logic could drift across files or branches
- repeated constants, validation, parsing, or transformation rules
- copy-paste updates across similar code paths

## Flag

- near-duplicate helpers with only cosmetic differences
- duplicated rules or literals that should be centralized
- repeated workflow glue that now wants one helper

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
