---
hash: "c4ac5295b1e243167f05249b6faabb721ed5045cd2d3bc602ea050d373e556e9"
name: agent-core
description: Coordinate subagents or teammates with clear roles, bounded tasks, source-of-truth ownership, and concise synthesis.
---

# agent-core

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `subagent-orchestrator`

# Subagent Orchestrator Playbook

Use this skill whenever a task could be delegated to one or more subagents.

## Primary goals
1. Finish faster through delegation and concurrency.
2. Keep parent context small by passing files/artifacts instead of long chat summaries.

## Agent role defaults in this project
- Use **Gemini Flash Lite** for long-context tasks: research, search, docs, large file/context reading, scanning, indexing, and synthesis over lots of text.
- Use **MiniMax M2.7** for short-horizon execution: tool use, CLI work, coding, edits, validation loops, and following an already detailed plan.
- Do **not** use Gemini for coding or edit-heavy implementation; route those to MiniMax unless the user asks otherwise.

## Decision rubric
- Ask the user which agent method to use when a new split-work task is not already clear; if they do not choose, use the existing/default method: `pi-subagents`.
- **Single mode**: one clear, bounded task with one specialist.
- **Chain mode**: task has handoff stages (discover -> plan -> implement -> review).
- **Parallel mode**: independent units can run concurrently.
- **pi-teams optional mode**: visible, long-lived teammate panes/windows, `/btw`-style side-channel work, or plan-approval work that should not interrupt the main agent.
- **pi-messenger-swarm coordination**: durable task board, path reservations, progress evidence, and cross-session memory around any multi-agent method.

## Design-agent default
- For UI, interaction, or visual design work, use a stronger design agent for the first concept-setting pass when the main problem is direction, taste, layout, or component feel.
- After the direction is set, hand follow-on refinement, implementation, and polish loops to cheaper agents.
- Reuse the stronger design agent only when the concept itself needs to be reconsidered, not for routine iteration.
- Keep design-agent usage budget-aware: aim for about **$1-5 total session spend**.
- If one premium design-agent call comes back around **$2-5**, do not schedule multiple more by default; switch to cheaper follow-up agents or ask the user first.
- Do not parallelize heavy/staff design agents by default.

## Fan-out defaults
- Prefer **3-6** child tasks when a problem naturally splits into independent angles.
- Hard cap: **10** child tasks.
- Prefer one useful decomposition layer, then synthesis.
- Let smart agents fan out.
- Keep `agent-lite` as leaf workers.
- For premium design work, prefer **one** concept-setting call and then cheap leaf workers.

## New-task kickoff (quick gate)
Before delegating on a brand-new task/project, do a 10-second gate:
1. Ask: "Want me to run this with subagents, or keep it single-agent?"
2. If unclear scope, run one tiny recon with `agent-lite` first.
3. Show this mini flow and choose path:

```text
Start
 ├─ Small + clear? ── yes ─> Single (agent-lite)
 │
 └─ no
    ├─ Needs discovery? ─ yes ─> agent-lite first
    └─ Multi-stage? ───── yes ─> Chain
                         no  ─> Parallel micro-tasks + one agent-lite fan-in
```

## Context-saving rules (important)
- Treat agents as scoped work packets/context wrappers first; async execution is only an optimization.
- Prefer synchronous subagents when the parent is blocked on the result needed for the next decision.
- Use parallel sync when multiple reviews or scans can run together and the parent needs all results before deciding.
- Use async only when the parent has genuinely independent work to do or the task is a long background scan; do not launch async just to poll.
- Do not delegate shell-only capture/build commands to an agent profile unless that agent has shell/tool execution. If not, run the command directly and delegate review/synthesis.
- Prefer `output` files (`context.md`, `plan.md`, `research.md`) over long inline text.
- Pass only needed files via `reads` in next steps.
- Keep each child task narrowly scoped with explicit acceptance criteria.
- Ask children for concise outputs (bullets + file paths + line ranges).
- When delegating design work, front-load context in the prompt: exact file paths, relevant snippets or summaries, current layout notes, ASCII sketches, user preferences, and locked constraints. Avoid making the child spend tokens rediscovering basics.

## Failure recovery
- When a subagent run fails, first summarize the failure, current parent state, useful context already gathered, and intended next steps.
- Fix or disable the blocker in the smallest safe way, then respawn the original delegation shape unless the user changes direction.

## Recommended patterns

### 0) Render screenshot iteration packet
Use for RenderBuddy/render/lighting/material work where visual context can balloon.

1. Parent writes a 20-50 line status packet: current goal, exact files, latest screenshot paths, locked constraints, and the one decision needed.
2. If build/capture commands must run and no capable shell subagent is available, parent runs them directly; otherwise assign a synchronous lite/coder packet with exact commands and acceptance criteria.
3. Run review/design agents as scoped packets with screenshot paths, baseline comparison paths, and one focused question such as "commit, tweak, or revert?".
4. Parent chooses the smallest next change, edits, verifies, commits, pushes, and appends the iteration log.
5. Use async only when parent can do useful independent work while captures/reviews run; avoid status-polling loops.

### 1) Fast coding pipeline (default)
1. `agent-lite` -> produce `context.md`
2. `agent-lite` -> produce `plan.md`
3. `agent-lite` -> implement
4. `agent-lite` -> validate/fix

### 2) Bulk triage
- Run several `agent-lite` agents in parallel for classification/extraction.
- Feed consolidated output to one `agent-lite` for synthesis.

### 3) Research-driven implementation
1. parallel `agent-lite` angle passes -> optional local `agent-lite`
2. `agent-lite` synthesizes into `research.md`
3. `agent-lite` reads `research.md` + local context
4. `agent-lite` implements
5. `agent-lite` verifies

## Named fan-out patterns

### `scatter-gather`
- Use for broad tasks with independent angles.
- Fan out 3-6 narrow children.
- Gather into one smart parent for synthesis.

### `parallel-angle-research`
- Use for external research.
- Split into angles like docs, examples, alternatives, risks.
- Prefer `agent-lite` children, then `agent-lite` synthesis.

### `review-fanout`
- Use for medium/large reviews.
- Split into narrow checks like contracts, regressions, tests, consistency.
- Let `agent-lite` own the final verdict.

### `local-recon-fanout`
- Use for broad local discovery.
- Fan out `agent-lite` across directories or question slices.
- Feed the result to `agent-lite` for synthesis.

## Example subagent payloads

### Single
```json
{ "agent": "agent-lite", "task": "Map auth flow files and risks", "output": "context.md" }
```

### Chain
```json
{
  "chain": [
    { "agent": "agent-lite", "task": "Find files and call graph for {task}", "output": "context.md" },
    { "agent": "agent-lite", "task": "Plan implementation from {previous}", "reads": ["context.md"], "output": "plan.md" },
    { "agent": "agent-lite", "task": "Implement plan for {task}", "reads": ["context.md", "plan.md"] },
    { "agent": "agent-lite", "task": "Review/fix against plan", "reads": ["plan.md", "progress.md"] }
  ]
}
```

### Parallel
```json
{
  "tasks": [
    { "agent": "agent-lite", "task": "List TODO/FIXME in engine/" },
    { "agent": "agent-lite", "task": "List TODO/FIXME in docs/" },
    { "agent": "agent-lite", "task": "Find risky parser code paths" }
  ],
  "concurrency": 3
}
```

## Anti-patterns
- Don't send one huge ambiguous task to `agent-lite` if stages are obvious.
- Don't use `agent-lite` as the first choice for high-leverage design judgment when a stronger design agent would set direction better.
- Don't fan out multiple expensive design-agent calls in parallel just because a task has multiple angles.
- Don't keep spending on heavy/staff design passes once actual per-call cost suggests the session will likely run past about **$5** without checking with the user.
- Don't use one heavyweight child when the task clearly has 3+ independent angles.
- Don't dump full child transcripts into parent summaries.
- Don't parallelize tasks with file-write collisions unless using worktree isolation.
