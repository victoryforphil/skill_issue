---
hash: "b9faedcf16dfcb72e46dfbbfcfbabbbf98b9dfd01affa11b28f7583593300c43"
name: review-comments
description: Review comments for correctness, usefulness, stale explanations, noise, and better naming or structure that can make comments unnecessary.
---

# review-comments

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `review-comments`

# Review: Comments

Use this when checking comment quality.

## Rule

Comments should explain non-obvious intent, tricky invariants, external constraints, or vendor/platform gotchas.
Do not narrate obvious code.

## Check

- comments still match the code
- public APIs have the right amount of guidance
- tricky behavior has enough explanation
- obvious code is not padded with narration

## Flag

- stale comments
- comments that just restate the code
- missing comments around invariants or external constraints
- long comment blocks where a rename or split would be clearer

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
