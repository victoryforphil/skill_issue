---
name: review-tests
description: Review tests for regression coverage, meaningful assertions, brittle fixtures, missing negative cases, and alignment with behavior changes.
---

# review-tests

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `review-tests`

# Review: Tests

Use this when checking validation quality.

## Check

- changed logic has a narrow useful test or a clear reason not to
- edge cases and regressions are covered where risk justifies it
- tests match the changed behavior, not only happy paths
- the narrowest useful test command is clear

## Flag

- logic changes with no meaningful validation
- missing regression tests for bug fixes
- new branches or edge cases with no coverage signal
- tests that assert too little for the change they guard

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
