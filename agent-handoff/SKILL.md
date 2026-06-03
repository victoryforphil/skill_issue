---
name: agent-handoff
description: Create durable handoff memory and task notes for agent swarms, long sessions, and resumed work while avoiding private/runtime state.
---

# agent-handoff

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `swarm-handoff-memory`

# Swarm Handoff Memory

Use this when a session should leave lightweight durable context for future Pi agents.

## Goal

Post concise handoff notes to `#memory` so later sessions can recover decisions, blockers, commands, and next steps without rereading the full transcript.

## Rules

- Join first if the messenger is available.
- Use `#memory` for durable cross-session notes.
- Keep noisy work chatter in the current session channel.
- Promote only decisions, blockers, evidence, and next steps to `#memory`.
- Keep messages short enough to scan in `feed` output.
- Do not treat `#memory` as infinite storage; feed retention may prune old events.

## Message shape

Prefer:

```text
Decision: ...
Evidence: ...
Next: ...
```

For blockers:

```text
Blocked: ...
Tried: ...
Need: ...
```

## Commands

```ts
pi_messenger({ action: 'join' });

pi_messenger({
  action: 'send',
  to: '#memory',
  message: 'Decision: keep asset schemas repo-owned. Evidence: tests cover generated FlatBuffers. Next: verify malformed buffer rejection.',
});
```

Read recent memory before related work:

```ts
pi_messenger({ action: 'feed', channel: 'memory', limit: 20 });
```

## When finishing a session

Post one final `#memory` note with:

- current status
- changed files or area
- last useful verify command
- next concrete step

---

## Source: `task-notes`

# Skill: Task Notes

Use this skill when creating a small deferred task note in `docs/tasks/`.

## Rules

- Name files `kebab-case-topic.task.md`.
- Keep notes short; do not turn them into full implementation plans.
- Use `docs/tasks/` for deferred ideas and thoughts.
- Use notes or handoff docs for agent handoffs.
- Use `docs/plans/` for larger implementation plans.

## Format

```markdown
---
title: Short task title
created: YYYY-MM-DD
status: deferred
---

# Short task title

## Why

- One short reason this exists.

## Notes

- Any useful context.

## Todos

- [ ]
```

Allowed `status` values: `deferred`, `active`, `done`.

Blank todos are OK. Use a bare `- [ ]` when the task should stay intentionally open-ended.
