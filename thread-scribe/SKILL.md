---
name: thread-scribe
description: Invoke the scribe agent to export and trim finished OpenCode threads into .chat.md archives.
---

# thread-scribe

Use this skill when a thread is wrapping up and you want a clean archive of the session.

## What this does

- Uses the `scribe` subagent to export an OpenCode session by id.
- Produces a trimmed markdown transcript.
- Saves it to `.opencode/vault/chats/<name>.chat.md`.
- Supports periodic rolling exports for updated sessions.

## When to use

- User asks to export a conversation or session.
- You are finishing a long implementation thread and archiving would help.
- You want a lightweight transcript without tool spam.

## How to invoke

1. Get a session id (`ses_...`).
2. Launch the `scribe` subagent via the Task tool with a focused prompt:
   - include session id
   - include destination `.opencode/vault/chats`
   - request trimmed transcript only (no tool payloads)
3. Return the saved file path.

## Rolling/time-sliced mode

Use this when you want periodic background exports:

- One-pass backlog drain:
  - `python3 .opencode/scripts/scribe_export.py --pending --recent 30 --max-per-tick 3`
- Continuous rolling export:
  - `python3 .opencode/scripts/scribe_export.py --watch --interval 300 --recent 30 --max-per-tick 2`

Notes:
- The script tracks exported state in `.opencode/vault/chats/.scribe-state.json`.
- `--max-per-tick` gives time-sliced behavior so each interval only processes a bounded number of sessions.
- For background runs, use PTY session tools or `tmux`.

## Automatic invocation guideline

Always auto-invoke this skill at thread wrap-up when producing a final summary/report.

### Trigger conditions

Run the export automatically when any of the following occurs:

- You write an end-of-thread implementation summary.
- You write a handoff report / status report / recap for completed work.
- The user requests a "what did we do" or similar closeout summary.
- A session id is present in context (for example: `opencode -s ses_...`) and the response is a wrap-up.

### Required behavior

- Do not ask for confirmation in these wrap-up cases.
- Invoke the `scribe` subagent and save to `.opencode/vault/chats/<name>.chat.md`.
- Return the saved archive path in the final response.

### Naming guidance

- Prefer a stable, date-scoped file name with topic context.
- If a session id is available, include a short suffix from it.
  - Example: `.opencode/vault/chats/2026-03-07-geo-simplify-modifiers-ses_3388fd41.chat.md`
