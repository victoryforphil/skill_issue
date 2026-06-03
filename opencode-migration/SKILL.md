---
hash: "e42390856aa6f6f4cc038d33e4409213b0a47deeded4f7d0b064bd95c6d45096"
name: opencode-migration
description: Migrate reusable OpenCode assets into chappie with consistent routing, style, and safety checks.
---

## What I do

- Migrate skills, commands, agents, tools, and script helpers from other repos.
- Adapt them to chappie conventions from `AGENTS.md` and `STYLE.md`.
- Enforce safety: no secrets, no accidental overwrites, no broken references.

## When to use me

Use this skill when you need to:

- Port `.opencode/*` assets from projects like tinyversal or dark-factory
- Convert source-specific workflows into reusable chappie workflows
- Build migration PRs with predictable output and validation

## Workflow

1. Discover
   - Inventory source assets and dependencies
   - Keep only reusable, non-sensitive items
2. Adapt
   - Update frontmatter, paths, and skill/agent references
   - Remove secrets and project-specific assumptions
3. Integrate
   - Place files in final `.opencode/` and `scripts/` locations
   - Update docs/cross-links when entrypoints change
4. Verify
   - Test command/skill invocation
   - Run `bun scripts/normalize_bun_scripts.sh.ts` if scripts changed

## Guardrails

- Route OpenCode system changes through `@dax`.
- Do not overwrite existing assets without explicit confirmation.
- Keep naming clear and collision-free.

## Output contract

Return:

- Migrated assets (source -> destination)
- Transformations applied
- Files created/updated
- Validation run + rerun commands
- Open risks or follow-ups

## Reference

- `kits/dax/opencode_migration_guide.md`
