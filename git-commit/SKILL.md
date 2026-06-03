---
name: git-commit
description: Plan and create sensible git commits from the current tree with status/diff inspection, safe staging, concise messages, and explicit push approval.
---

# git-commit

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `style-git-commits`

# Style: Git and Commits

Read active repo `STYLE.md`/`AGENTS.md` first.

Use this skill when:
- preparing commits
- choosing commit boundaries
- writing commit messages
- checking whether a diff should be split
- quickly committing the current working tree

## Goals
- Usually make **1 commit**.
- Make **2 commits** only if there is an obvious split.
- Allow more commits when the tree clearly contains multiple real work units.
- Keep the final tree clean, or clearly report why not.

## Quick flow
1. Check `git status --short`.
2. Review changed paths and diff summary.
3. Ask once at the start whether to push after commit.
4. Decide commit buckets:
   - 1 by default
   - 2 if there is a clean split
   - more only if clearly separate work units
5. Commit each bucket with concise project-style titles.
6. Push if approved.
7. End with a clean `git status --short`, or report leftovers.

## Rules
- Commit one clear unit at a time.
- Prefer scoped commits over grab-bag commits.
- Keep titles short and predictable.
- Prefer the active repo commit style. If no style is defined, use a short imperative title such as `docs: add skill validation`.
- Do not create `misc` commits.
- Keep unrelated leftovers unstaged unless the user wants them included.
- Summarize leftovers clearly if the tree is not clean.

## Optional quick subagent help
Use subagents to speed up grouping and absorb context, not to overthink.

- Default: use **1 `agent-lite`** when the grouping is not trivial.
- If broad: spawn **2 parallel `agent-lite`** helpers by directory or file group.
- Parent agent still decides staging, final commit messages, and push behavior.

## Good
- `Agents // add repo style rules and style skills #tooling #ai`
- one commit for docs/skills, another for engine/runtime changes
- one commit for a single focused session

## Bad
- `misc fixes`
- one commit mixing style docs, project changes, vendor updates, and cleanup
- splitting one small session into many tiny commits

## Suggested commands
- `git status --short`
- `git diff --stat`
- `git diff --name-only`
- `git add -p`
- `git commit -m "..."`

## Return contract
- commit hash + title per commit
- short file grouping summary
- skipped files and reasons
- final `git status --short`

---

## Source: `git-quick-commit`

# Git Quick Commit

Use this when the user wants the **current working state committed now**.

## Read first
- `STYLE.md`
- `the relevant local/global skill style-git-commits/SKILL.md`

`style-git-commits` is the default style/source of truth for commit boundaries and titles.
This skill is the quick execution workflow built on top of it.

## Goal
- Commit the current tree quickly.
- Usually make **1 commit**.
- Make **2 commits** only if there is an obvious split.
- Allow more commits when the tree clearly contains multiple real work units.
- Do not over-split.

## Quick flow
1. Check `git status --short`.
2. Review changed paths and diff summary.
3. Ask once at the start whether to push after commit.
4. Choose the smallest sensible set of commit buckets.
5. Stage and commit each bucket.
6. Push if approved.
7. End with a clean `git status --short`, or clearly report why not.

## Optional subagent help
Use subagents to speed up grouping and absorb context, not to overthink.

- Default: use **1 `agent-lite`** when the tree is not trivially obvious.
- If broad: spawn **2 parallel `agent-lite`** helpers by path group.
- Parent agent decides final staging, commit messages, and push behavior.

## Output
Report:
- commit hash + title per commit
- short grouping summary
- leftovers/skipped files
- final `git status --short`
