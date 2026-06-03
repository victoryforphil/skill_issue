---
name: style-docs
description: Write and review concise, scannable, decision-focused docs, prompts, skill files, and handoff notes while following local repo conventions.
---

# style-docs

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `style-docs-writing`

# Style: Docs and Writing

Read active repo `STYLE.md`/`AGENTS.md` first.

Use this skill for:
- `README.md`
- `AGENTS.md`
- `STYLE.md`
- docs under `docs/`
- prompt templates under `.pi/prompts/`
- skills under `the relevant local/global skill `

## Rules

- Lead with the decision, rule, or purpose.
- Prefer short sections and bullets.
- Use examples when they remove ambiguity.
- Link to deeper docs or skills instead of duplicating them.
- Keep prompt bodies short; keep durable behavior in agents and skills.
- For `docs/plans/*.md`, add a top `---- KICK OFF PROMPT ----` section after frontmatter with: repo realpath, plan realpath, current scope, autonomy question, and a short instruction to iterate/build/test until success or a real human blocker.
- When adding a new convention, prefer one short rule in `STYLE.md` over repeating prose in many files.
- Keep style-related skills consistently prefixed with `style-`.

## Good

- `Goal`, `Rules`, `Verify`, `Risks`
- one short example
- one link to the deeper source of truth

## Bad

- long narrative setup before the actual rule
- repeating the same convention in every prompt
- large walls of text with weak headings
