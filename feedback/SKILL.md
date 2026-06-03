---
name: feedback
description: Capture repeated user feedback into the smallest durable home: style docs, skills, review rules, memories, or local project guidance.
---

# feedback

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `feedback`

# Feedback Intake

Use this when the user gives style, review, workflow, or memory feedback.

## Goal

Turn feedback into the smallest durable home:

- `STYLE.md` for short repo conventions
- a skill for reusable workflow or procedure
- a review rule for review behavior
- `MEMORY.md` later for broader project memory

## Flow

1. Read `STYLE.md`, relevant existing skills, and `.agents/review-rules/`.
2. Decide the narrowest durable target.
3. Draft or edit that file.
4. If the feedback is ambiguous, ask for the split instead of guessing.

## Routing

- repeated repo convention -> `STYLE.md`
- reusable workflow or procedure -> skill
- review behavior or enforcement -> review rule
- long-lived memory -> `MEMORY.md` when the repo starts using it
- continuous-learning instincts/facts -> advisory input; validate and route through this flow before making durable repo changes

---

## Source: `pi-continuous-learning`

# Pi Continuous Learning

Use this skill when working with `pi-continuous-learning` instincts, facts, analyzer output, or graduation suggestions.

## Source of truth

Continuous-learning memory is advisory. Durable repo rules still belong in:

- `STYLE.md` for short repo conventions
- `the relevant local/global skill ` for reusable procedures
- `.agents/review-rules/` for review behavior
- `MEMORY.md` later if the repo adopts it

Use `the relevant local/global skill feedback/SKILL.md` before making durable changes from learned instincts.

## Data locations

The package stores user-local data under:

```text
~/.pi/continuous-learning/
  config.json
  projects.json
  analyzer.log
  instincts/personal/
  facts/personal/
  projects/<projectId>/observations.jsonl
  projects/<projectId>/observations.archive/
  projects/<projectId>/instincts/personal/
  projects/<projectId>/facts/personal/
```

## Commands

Useful Pi commands after installation:

```text
/instinct-status
/instinct-dream
/instinct-evolve
/instinct-graduate
/instinct-promote
/instinct-projects
/instinct-export
/instinct-import
```

Analyzer command:

```bash
pi-cl-analyze
```

## Rules

- Treat instincts and facts as suggestions, not authority.
- Do not run `/instinct-graduate` into repo files without explicit user approval.
- Prefer `/feedback` for repeated user preferences or workflow corrections.
- Promote only specific, repeated, useful behavior; delete vague or generic agent-hygiene instincts.
- Avoid duplicate memory systems: if a rule already exists in `STYLE.md`, a skill, or a review rule, do not add another copy.
- Cite session/transcript evidence when practical before promoting an instinct.
- Keep project-specific instincts project-scoped unless they clearly apply across repos.

## Privacy check

Before sharing or promoting learned data, remember observations may include:

- prompts
- tool args/results
- failed tool output
- bash commands
- project paths and model selections

Secret scrubbing is best-effort regex matching, not a guarantee. Do not paste raw observations into docs or prompts unless reviewed.
