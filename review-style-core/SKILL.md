---
name: review-style-core
description: Review for repo-wide style, code quality, duplication, comments, function sizes, and non-defensive/compatibility issues.
---

# Review: Style Core

Use this skill when performing code reviews and quality checks. It translates the core style pillars into concrete review checkpoints.

## Checkpoints

### 1. Smallest Correct Diff
- **Check:** Does the change do *only* what was requested?
- **Flag:** Unrelated cleanup, broad refactorings, or unrelated stylistic changes mixed into the functional diff.

### 2. Pragmatic DRY
- **Check:** Are abstractions genuinely removing maintenance risk, or are they premature?
- **Flag:** Complex helpers or wrappers created for 2-3 lines of simple local code. Ensure local, obvious code is preferred over indirect abstractions.

### 3. LOC & Shape
- **Check:** Are functions short with a single responsibility? Are files easy to scan?
- **Flag:** Long functions with mixed phases (e.g., mixing validation, hardware I/O, and status logging in one block). Flag files with multiple public types or mixed concerns.

### 4. Comment Noise
- **Check:** Do comments explain *why* something is done?
- **Flag:** Obvious narration comments. Flag missing comments around hardware invariants or external constraints (e.g., SPI bus timing or GPIO mappings).

### 5. Flow & Non-Defensive Programming
- **Check:** Is the "happy path" clean, flat, and obvious?
- **Flag:** Deeply nested control flow (more than 3 levels of nesting). Flag excessive defensive boilerplate (redundant checks inside leaf functions) that can be replaced by a clear precondition/assertion.

### 6. Legacy / Compatibility Abuse
- **Check:** Are we cleanly evolving the codebase, or are we piling up wrappers to avoid touching existing code?
- **Flag:** Avoiding necessary refactoring of small, broken local APIs by adding yet another layer of compatibility wrapping.

---

## Output Format
Return only concrete findings with file paths, line numbers, and evidence, or simply output `looks good`.
