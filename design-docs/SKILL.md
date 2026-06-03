---
hash: "bed9711d123bdd7190e8e606407a7a1649d77ae6bf0afe46c3865ad7ce6808ab"
name: design-docs
description: Write and maintain design/decision docs in docs/designs/ for every system or change, so agents can recover context after sessions.
---

# Design Docs

Design docs live in `docs/designs/`. They capture decisions, architecture,
API surfaces, trade-offs, and rationale for every subsystem an agent creates
or modifies. Agents **must** update (or create) a design doc whenever they
introduce, change, or remove a system.

## When to write

- When you build a new system, protocol, or component.
- When you change an existing design doc's subject.
- When you discover a constraint or trade-off that was not documented.
- Do **not** write design docs for one-shot research or learning notes
  (those go in `docs/learning/`).

## File structure

Each file uses the template at `docs/designs/TEMPLATE.md`.

```
---
title: Short Title
tags: [comma, separated]
status: draft | active | deprecated
---
# Short Title

## Context

Why this system exists, what problem it solves, what alternatives
were considered.

## Architecture

High-level structure: components, data flow, boundaries.

## Interfaces

Public API surfaces — CLI flags, function signatures, shell commands,
protocol messages, etc.

## Trade-offs

Explicit trade-offs made and why.

## Current Status

What works, what does not, what is planned next.
```

## Updating

- Edit in place when a system evolves.
- Bump a `last_updated` date in frontmatter if the file has one.
- Mark `status: deprecated` (don't delete) when a system is replaced.

## Index

`docs/designs/README.md` contains a table-of-contents. Update it when
you add or remove a design doc.
