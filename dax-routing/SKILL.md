---
name: dax-routing
description: Route OpenCode systems tasks to the dax subagent.
---

## What I do

- Route OpenCode systems work to `@dax`.
- Keep OpenCode-related changes centralized in the Dax workflow.
- Ensure outputs include changed files, behavior impact, and validation steps.
- Treat `.opencode/agents/dax.md` as the canonical behavior definition.

## When to use me

Use this skill when tasks involve:

- `.opencode/` agents, commands, skills, tools, or permissions
- OpenCode config structure, instruction loading, or `{file:...}` references
- OpenCode workflow setup and maintenance

## Routing contract

When invoked, pass to `@dax`:

- Goal and constraints from the user request
- Exact OpenCode files/paths in scope
- Any safety requirements or style constraints from `AGENTS.md` and `STYLE.md`

Expect from `@dax`:

- Files changed + intent
- Behavior impact
- Validation commands run (or manual verification)
