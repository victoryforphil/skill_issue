---
hash: "9f7d0b1a6809926836302741a8a5e0313e5648dd548700dfd3b099f8e5387858"
name: vfp-style-git
description: Inform git commits, commit grouping, branch prep, and related git operations with VFP-style guidance.
---

## What I do

- Provide a simple style guide for git commits and related git operations.
- Keep commit grouping, final cleanup, and branch/PR prep consistent.
- Encourage predictable summaries, clear commit messages, and clean final status.

## When to use me

Use this whenever:

- The user asks for commits or working tree cleanup.
- Changes should be grouped into sensible commit units.
- Branch naming or PR preparation should follow a consistent style.
- You want a quick reminder of preferred git workflow conventions.

## Workflow guidance

1. **Summarize first**: understand the diff and identify commit buckets.
2. **Commit by unit**: make scoped commits for each logical change.
3. **Finish cleanly**: verify `git status --short` and report leftovers.
4. **Prepare handoff**: if needed, draft branch/PR details from the commit intent.

## Style templates

- Commit title:
  - `{System} // {Desc} #tag-one #tag-two`
  - If there is an issue reference, prepend it. If not, do not add a `[NO-ISSUE]` prefix.
- Branch naming:
  - `vfp/agent/{branch_name}`
- PR body:
  - `## Scope`
  - `## Risks`
  - `## Verification`

## Suggested handoff context

When coordinating git work, include:

- Goal: <requested outcome>
- Scope: <paths or feature area>
- Strategy: <summary | scoped commit | pr-prep>
- Boundary: <exact files or globs>
- Clean-state requirement: <must end clean | approved leftovers>
- Notes: <tests run, constraints, message style>

## Return contract

- Commit plan or executed commits (hash + title + files)
- Skipped files and reasons
- Final `git status --short` summary
- If PR requested: title + body draft
