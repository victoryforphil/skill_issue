---
hash: "93caba01ed7120d3c18d40160723919b71d8b01753bc74412a3b57e587b6dbde"
name: style-git-commit
description: Self-contained git commit skill following the Loki repo conventions. Any agent can load this and commit in the repo's style without needing a subagent.
---

## What I do
- Enforce Loki commit conventions: format, grouping, no secrets, no push unless asked.
- Let any agent commit directly — no subagent delegation needed.

## When to use me
Use whenever the user asks for commits, when a task introduces meaningful changes, or when the working tree should be cleaned up into commits.

## Workflow
1. Run `git status`, `git diff`, and `git log --oneline -10` to understand scope and message style.
2. Summarise changes for the user in 2-6 bullets.
3. Draft a commit message in the required format.
4. If explicitly asked to commit, stage relevant files and commit.

## Commit rules
- Follow conventions from AGENTS.md exactly.
- Format: `{Component/Meta} // {Optional Addition section} // {Description, Short} (Optional,Tags)`
  - Examples:
    - `Docs // Added converted PDF docs`
    - `Drivers // UWB // Added initial DW3000 SPI driver (WIP)`
  - The "addition section" is optional (~80/20 split).
- Do not commit secrets or sensitive files.
- Do not push unless explicitly requested. At most, ask first — user must review before upstream push.
- If user asks to "commit all" or "clear git status", group related changes into a few commits when it makes sense; otherwise commit everything together.
- If no reasonable grouping exists, use a single commit.
- Worst-case fallback: `Meta // Sync Update`.
- In the commit body, add a short rationale line and sign it as: `// Agent (your model if you know)`.
- If a hook modifies files after commit, include those changes in a new commit (do not amend unless asked).

## Working with branches
- If working with the user, commit on the current branch.
- If working autonomously, ask the user about which branch to use.
- `gh` CLI is available for GitHub tasks.

## Handoff (for parent agents)
When handing commit work to an agent that has loaded this skill, provide:
- Goal: what the user asked for
- Scope: files or areas touched
- Notes: any constraints, tests run, or commit grouping preferences
