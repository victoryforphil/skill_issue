---
hash: "5741ae9e8aa1c555ab3a81cb2b8952162f7be46bfccdff36f107bd0132147547"
name: pi-worktree-status
description: Use the pi-messenger workspace channel as shared global context for what agents are working on, which repos/worktrees/branches exist, and their relative paths. Load when starting work in a repo/worktree, switching branches, coordinating with other agents, or needing to query current workspace usage.
---

# Pi Worktree Status Channel

Use `#workspace` as the short shared map of active projects, worktrees, branches, and agent ownership. Keep posts compact: metadata + state + paths, with only 1–3 bullets.

## Before work: join and query

```ts
pi_messenger({ action: "join", channel: "#workspace", create: true });
pi_messenger({ action: "feed", channel: "#workspace", limit: 20 });
```

Use the feed to learn:
- Which repos/worktrees/branches already exist and where they live.
- Which agent appears to be using or editing a worktree.
- Whether your intended path/branch is free, stale, active, blocked, or done.

## Post status updates

Send one update when you start, when you materially change state, and when you finish/abandon a worktree.

```ts
pi_messenger({
  action: "send",
  to: "#workspace",
  message: `[active] agent=<name> repo=<repo> branch=<branch> worktree=<relpath-or-abs-path> cwd=<cwd>
- Working on: <short task>
- Paths: <important dirs/files>
- State: <active|blocked|done|stale>, notes=<optional>`
});
```

## Message format

Prefer this shape, short and searchable:

```text
[active] agent=Implementer repo=real_agi_i_promise branch=feat/foo worktree=../real_agi_i_promise-feat cwd=/Users/alex/repos/vfp/real_agi_i_promise
- Working on: add auth smoke tests
- Paths: src/auth/, tests/auth.spec.ts
- State: active, since=2026-04-24, owner=Implementer
```

States:
- `active`: currently using/editing the worktree.
- `blocked`: waiting on user/agent/tool; include blocker.
- `done`: finished; include summary and whether cleanup is safe.
- `stale`: no longer actively used or uncertain ownership.

## Good use

- Query `#workspace` before creating a new worktree, reusing an existing branch, or editing shared paths.
- Post paths as repo-relative when possible; include absolute `cwd` or worktree root when location matters.
- Do not include long logs, diffs, secrets, or detailed plans; this channel is only a compact workspace map.
