---
name: style-cpp
description: Apply broadly useful modern C++ style: clear ownership, RAII, simple control flow, focused files, and readable low-cleverness implementation.
---

# style-cpp

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `style-cpp`

# C++ Human Style

Read active repo `STYLE.md`/`AGENTS.md` first for the short repo-wide rules. Use `style-core` for the repo-wide lens, then use this skill for the fuller C++ lens.

This repo wants assisted C++ that still reads like careful human work.

## Bias

Prefer:
- small, correct diffs
- clear ownership and lifetime
- obvious names
- readable control flow
- ordinary data structures
- local consistency over generic cleverness

Avoid:
- speculative abstractions
- mini-frameworks during feature work
- heavy template machinery without a strong reason
- noisy comments
- hidden ownership rules

## Default rules

- Prefer RAII and value semantics first.
- Prefer stack values and `std::unique_ptr` over shared ownership.
- Use `const`, `constexpr`, and `noexcept` when they clarify intent.
- Keep headers lean; keep non-template logic in `.cpp`.
- Prefer `enum class` over unscoped enums.
- Prefer composition over inheritance.
- Match surrounding style before introducing a new one.

## Comments

Comment only when explaining:
- non-obvious intent
- tricky invariants
- external constraints
- platform or vendor gotchas

Do not narrate obvious code.

## Shape

- Prefer short functions with one clear job.
- Pass dependencies explicitly.
- Keep APIs narrow and unsurprising.
- Use helpers when they remove repetition without hiding the flow.
- Put durable public API types in focused headers under a grouped `types/` directory when that keeps the surface easier to browse (for example `types/core/`, `types/resources/`, `types/debug/`).

## Output parameters

- Prefix output/write-only parameters, struct members, and local vars with `out` (camelCase): `Bounds& outBounds`, `RenderFrame outFrame`.
- Never use `result`, `ret`, `r`, or unprefixed names for write-only targets — the `out` prefix signals intent at the call site.
- Applies equally to struct members that are write targets (e.g. `RenderContext::outFrame`).

## Public type names

- Prefer short, role-clear nouns for public API types when they stay unambiguous.
- Good examples: `RenderFrame`, `MeshInstance`, `DebugPrimitives`.
- Avoid suffix-heavy names when they add noise more than clarity.

## Avoid unless asked

- large renames
- broad header reshuffles
- new base classes or registries
- cross-cutting ownership changes
- replacing straightforward code with clever library tricks

## Final check

Before finishing, ask:
- Is this the smallest correct change?
- Would a teammate understand it quickly?
- Did I preserve local style?
- Did I avoid inventing a framework?
- Is ownership obvious?

If the user gives repeated style feedback, add or refine a short rule in `STYLE.md`.

---

## Source: `review-style-cpp`

# Review: Style C++

Use this for C++ and C++/project-adjacent review.

Load these lenses mentally:
- `style-cpp`
- `review-cpp-engine`

## Check

- ownership and lifetime are obvious
- control flow is boring and readable
- headers stay lean; boundaries still make sense
- public API names stay short and role-clear
- output/write-only targets use the `out` camelCase prefix
- comments explain non-obvious intent, not line-by-line behavior

## Flag

- hidden ownership or surprising coupling
- heavy abstraction on simple paths
- header / implementation boundary drift
- suffix-heavy or unclear public type names
- noisy comments or missing invariant comments where needed

## Output

Return only concrete findings with file paths and evidence, or `looks good`.
