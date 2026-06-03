---
hash: "67b5c5b9b5bfaca3c7eed2142d7328ca27c76827d9c26c03d1bb77e0115b6c15"
name: skill-scraper
description: >
  Generates a new OpenCode expert skill from a docs.rs URL. Load when asked
  to scrape, create, or build a library skill from a docs.rs link.
---

# skill-scraper

You are an expert at reading Rust crate documentation and distilling it into
a concise, high-signal OpenCode skill file that makes future agents instantly
expert in that library.

---

## Workflow

When given a docs.rs URL (or just a crate name), follow these steps exactly.

---

### Step 1 — Parse the URL

Extract:
- **`crate_name`** — e.g. `bevy`, `tokio`, `serde`
- **`version`** — version string or `latest`
- **`root_url`** — canonicalised to `https://docs.rs/<crate>/latest/<crate>/`

Accepted URL patterns:
```
https://docs.rs/<crate>/<version>/<module>/
https://docs.rs/crate/<crate>/<version>/
```

If only a bare crate name is given, construct:
`https://docs.rs/<crate>/latest/<crate>/`

Normalise `crate_name` to `^[a-z0-9]+(-[a-z0-9]+)*$` (replace `_` with `-`).

---

### Step 2 — Fetch documentation

Use **WebFetch** with `format: "markdown"`. Fetch in priority order; stop when
you have enough signal (typically 3–5 pages).

| Priority | Target | Signal |
|----------|--------|--------|
| 1 | Root page — `https://docs.rs/<crate>/latest/<crate>/` | tagline, module list, re-exports, feature flags |
| 2 | `prelude` module (if it exists) | everyday API surface |
| 3 | 2–4 modules that look most central | structural coverage |
| 4 | Individual pages for the 5–10 most prominent types | signatures, fields, impl blocks |
| 5 | README / repo link if discoverable | examples, philosophy, gotchas |

Do **not** attempt to fetch every page — prioritise breadth over depth.

---

### Step 3 — Analyse and synthesise

Build a mental model covering:

- **Purpose** — one sentence: what the crate does and when to reach for it
- **Key types** — structs/enums/traits users touch most day-to-day
- **Core traits** — what users implement or consume, whether derivable
- **Idiomatic patterns** — builder, derive macros, plugin system, async model, etc.
- **Feature flags** — optional capabilities behind Cargo features
- **Gotchas** — footguns, version differences, common trip-ups
- **Module map** — which modules own which concerns

---

### Step 4 — Generate the skill file

Produce content using the template below. Fill **every** section; leave no placeholder text.

````markdown
---
name: <crate-name>
description: >
  Expert knowledge of the `<crate-name>` Rust crate (<version>). Load when
  working with <crate-name> — covers key API, types, traits, patterns, and
  navigation tips scraped from docs.rs.
---

# `<crate-name>` — Expert Reference

> <one-line tagline copied verbatim from docs.rs>

**Docs:** https://docs.rs/<crate-name>/latest/<crate-name>/  
**Version captured:** <version>

---

## Overview

<2–4 sentences: purpose, design philosophy, primary use-cases>

---

## Key Types

| Type | Kind | Purpose |
|------|------|---------|
| `TypeName` | struct / enum / trait | what it is and when you use it |

_Minimum 5 entries. Add a `Feature` column if a type requires a non-default feature flag._

---

## Key Traits

| Trait | Implement to… | Derivable? |
|-------|--------------|-----------|
| `TraitName` | short description | `#[derive(TraitName)]` / manual |

---

## Core Patterns

### <Pattern name>
```rust
// Minimal, correct, idiomatic code snippet
```
<1–3 sentence explanation of when/why>

### <Pattern name>
...

_Minimum 2 patterns._

---

## Module Map

| Module path | Contains |
|-------------|---------|
| `crate::module` | what lives here |

_Cover every top-level module visible on the root docs page._

---

## Feature Flags

| Flag | Enables | Default? |
|------|---------|---------|
| `feature-name` | what it unlocks | yes / no |

_Write "No optional features" if none exist._

---

## Gotchas & Tips

- <concrete tip or footgun — be specific>
- <concrete tip or footgun>

---

## Useful Links

- [Crate root](https://docs.rs/<crate>/latest/<crate>/)
- [GitHub / source](<repo URL if found, else omit>)
- [Changelog](<changelog URL if found, else omit>)
````

---

### Step 5 — Save the skill

Write the generated content to the **project-local** skills directory:

```
<project-root>/.opencode/skills/<crate-name>/SKILL.md
```

- Determine `<project-root>` from the current working directory (the repo root
  containing `.opencode/`).
- Create the directory with `mkdir -p` if it does not exist.
- Use the **Write** tool with the full absolute path (never `~`).
- The directory name **must** exactly match `name` in the frontmatter.

---

### Step 6 — Confirm

After saving, output a concise summary:

```
Skill saved: .opencode/skills/<crate-name>/SKILL.md

Captured:
  ├─ types     <N> key types
  ├─ traits    <N> key traits
  ├─ patterns  <N> code examples
  ├─ modules   <N> module entries
  └─ pages     <N> docs pages fetched
```

---

## Quality checklist (verify before saving)

- [ ] `name` in frontmatter matches the directory name exactly
- [ ] `name` satisfies `^[a-z0-9]+(-[a-z0-9]+)*$`
- [ ] `description` contains the library name so the skill auto-triggers
- [ ] Key Types table has ≥ 5 entries with no placeholder rows
- [ ] At least 2 working code examples in Core Patterns
- [ ] Module Map covers every top-level module from the root docs page
- [ ] Feature Flags section is filled or marked "No optional features"
- [ ] No placeholder text (`...`, `<fill>`, `TypeName`, etc.) left in output
- [ ] File written to the correct absolute path under `.opencode/skills/`
