---
name: style-guide
description: Applies STYLE.md conventions during implementation and review. Use for code changes, refactors, and output formatting decisions.
---

# Style Guide Skill

Use this skill whenever you are writing or modifying source code.

## Priority order

1. Project-level `STYLE.md` in the active repository (if present).
2. Profile-level `~/.config/opencode/profiles/local/rules/STYLE.md`.
3. Existing repository conventions when no explicit style guide is available.

## Required behavior

- Before coding, look for project-level `STYLE.md` and apply it first.
- Keep edits readable, explicit, and minimal-risk.
- Follow naming, error handling, and logging conventions from style docs.
- Prefer one clean implementation path and remove obvious dead code while editing.
- Keep changes small and easy to review.
- Prefer smaller files and focused modules over long multi-responsibility files.
- In TypeScript, group behavior into clear domain-oriented modules/structs/hooks/providers instead of large flat exports when that improves readability and navigation.

## When to use

- New feature implementation.
- Bug fixes.
- Refactors.
- Output/message format updates.

## Notes

- If project and profile style rules conflict, follow project-level `STYLE.md`.
- If no `STYLE.md` exists, follow established codebase conventions.
