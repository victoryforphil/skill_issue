---
name: pty-backend
description: Use opencode-pty for long-running backend sessions, interactive processes, and log-driven tasks.
---

# PTY backend tasks

## Goal
Use the `opencode-pty` plugin when a backend job needs to stay alive, accept input later, or stream output over time.

## Rules
- Prefer `pty_spawn` for dev servers, test watchers, migrations, REPLs, and other long-running backend tasks.
- Treat these as **sessions** when talking about them.
- Use `pty_read` to inspect logs or wait for a readiness marker.
- Use `pty_write` to send input, including control keys like `\x03` for Ctrl+C.
- Use `pty_list` to find active sessions.
- If you may need logs later, do `pty_read` before cleanup.
- Once the task is done, close the app/process and clean up the PTY. Do not leave stray GUI or backend sessions running.
- Use `pty_kill` with `cleanup=true` when the session is no longer needed.

## Workflow
1. Spawn a PTY session with a clear title.
2. Watch output until the process is ready.
3. Read only the relevant buffer range when checking logs.
4. Send input if the process prompts for it.
5. If logs matter, read them before cleanup.
6. Kill and clean up the session when the task is done.

## Example
```text
pty_spawn: command="npm", args=["run", "dev"], title="API session", notifyOnExit=true
pty_read: id="pty_123", limit=50
pty_write: id="pty_123", data="\x03"
pty_kill: id="pty_123", cleanup=true
```

## When not to use this skill
- One-shot commands that finish quickly.
- Tasks that do not need persistent output or later interaction.
