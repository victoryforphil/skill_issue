---
name: git-pr
description: Prepare, review, and approve pull requests safely with concrete evidence, clean status checks, and explicit approval for push/merge actions.
---

# git-pr

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `git-approve`

# Git Approve

Use this when the user says a PR looks good and wants it approved, merged, and locally cleaned up.

## Goal

- Approve the current PR when GitHub allows it.
- Merge the PR.
- Delete the remote and local feature branches.
- Clean up stale worktrees.
- Fetch/prune and fast-forward local `main`.

## Safety rules

- Do not force-push, reset hard, or amend.
- Do not delete a branch with uncommitted changes.
- If the current branch is `main`, merge the explicit PR but skip branch deletion unless the feature branch is known.
- If GitHub rejects approval because the PR is authored by the current user, continue to merge and report that approval was skipped by GitHub policy.
- If the PR is still draft and the user explicitly asked to merge it, mark it ready first with `gh pr ready <number>`.
- Prefer `gh pr merge <number> --merge --delete-branch` so GitHub deletes the remote branch.
- Use `git branch -d`, not `-D`. If deletion fails, report it instead of forcing.
- Use `git worktree prune` after branch deletion to remove stale worktree metadata.
- Use `git fetch --prune` and `git pull --ff-only` on `main`.

## Quick flow

1. Check context:
   - `git status --short --branch`
   - `gh pr status`
2. Resolve the PR:
   - Prefer the current branch PR.
   - If ambiguous, ask for the PR number.
3. Inspect PR state:
   - `gh pr view <number> --json number,title,author,headRefName,baseRefName,isDraft,mergeStateStatus,url`
   - Stop for drafts, dirty trees, unclear base branches, or non-clean merge state unless the user explicitly says to continue.
4. Approve and merge:
   - `gh pr ready <number>` if the PR is draft and the user explicitly said to merge.
   - `gh pr review <number> --approve`
   - If approval fails only because it is the current user's PR, continue.
   - `gh pr merge <number> --merge --delete-branch`
5. Clean local state:
   - Save `headRefName` from the PR before switching branches.
   - `git switch main`
   - `git branch -d <headRefName>` if it exists locally and is not `main`.
   - `git worktree prune`
   - `git fetch --prune`
   - `git pull --ff-only`
6. Verify:
   - `gh pr view <number> --json state,mergedAt,mergedBy,url`
   - `git status --short --branch`

## Output

Report:

- PR number and URL.
- Whether approval succeeded or was skipped by GitHub policy.
- Merge result.
- Remote and local branch cleanup result.
- Worktree prune result.
- Final local `main` status.
