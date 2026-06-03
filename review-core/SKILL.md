---
hash: "c6c5378839360876bb0de29c822407e5a2681f9422468e7b0da6b1f94b5dc4b7"
name: review-core
description: Review changes for scope control, maintainability drift, duplicate flows, and repo-wide style regressions; return only concrete findings or looks good.
---

# review-core

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `review-style-core`

# Review: Style Core

Use this for repo-wide review.

## Check

- smallest correct diff
- one clear path instead of parallel workflows
- maintenance exposure stayed flat or improved
- files stayed focused and easy to scan
- shared logging paths stayed unified when touching repo-owned apps and tools

## Flag

- unrelated cleanup mixed into the task
- duplicate paths, wrappers, or config layers
- kitchen-sink growth
- abstractions that do not remove real duplication or risk
- new direct logging patterns that bypass `project_logging` without a clear reason

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
