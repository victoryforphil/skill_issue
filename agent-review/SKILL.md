---
name: agent-review
description: Run multi-agent or council-style review workflows for code, docs, plans, and designs with concrete findings and final synthesis.
---

# agent-review

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `swarm-review-council`

# Swarm Review Council

Use this for broad reviews where multiple focused perspectives are useful.

## Goal

Run a short-lived reviewer council with explicit lanes, persisted findings, and one parent synthesis.

## Good review lanes

- C++ correctness, ownership, lifetime, API shape
- CMake/build graph and generated-file wiring
- tests and coverage gaps
- docs/workflow drift
- asset pipeline schemas/import behavior

## Protocol

1. Join the mesh.
2. Pick a channel: current session for noisy review, or a named channel for longer-lived work.
3. Create one task per review lane.
4. Spawn focused reviewers with `taskId` when possible.
5. Ask reviewers to post concise findings with severity and file paths.
6. Synthesize results in the parent session.
7. Promote durable conclusions to `#memory` when useful.

## Commands

```ts
pi_messenger({ action: 'join' });

pi_messenger({
  action: 'task.create',
  title: 'Review C++ project risks',
  content: 'Check ownership, lifetimes, API shape, and build fallout in the current diff.',
});
```

Spawn a reviewer:

```ts
pi_messenger({
  action: 'spawn',
  role: 'C++ Project Reviewer',
  persona: 'Skeptical about ownership, lifetime, API shape, and build fallout',
  message: 'Review the current diff. Post findings with severity, file path, and suggested fix. Mark the assigned task done with evidence.',
  taskId: 'task-1',
});
```

Inspect results:

```ts
pi_messenger({ action: 'swarm' });
pi_messenger({ action: 'feed', limit: 40 });
pi_messenger({ action: 'spawn.history' });
```

## Reviewer output format

Ask spawned reviewers to use:

```text
Finding: P1/P2/P3 - short title
Path: path/to/file
Evidence: what proves it
Fix: smallest safe change
```

## Rules

- Keep one parent agent responsible for final decisions.
- Keep reviewers advisory unless explicitly assigned implementation tasks.
- Avoid spawning reviewers for tiny diffs.
- Prefer narrow role prompts over generic “review everything”.
- Use existing repo review skills when they match the lane.

---

## Source: `walk-review`

# Walk Review

Use this when a PR needs a guided human review, not a full line-by-line code review.

## Goal

- Find code the human should decide on before patterns spread.
- Mark representative style with `// [SAMPLE]`.
- Mark sketchy, debatable, legacy, or mass-change candidates with `// [REVIEW_ME]`.
- Keep findings short enough to discuss live.

## Tags

- `// [REVIEW_ME]`: human choice needed; possible bug, hack, unclear ownership, naming, compatibility, or architectural direction.
- `// [SAMPLE]`: representative pattern; use as a style exemplar or decide to mass-apply/change it.
- `// [DEFER yyyy-mm-dd HH:MM]`: intentionally postponed; include current local date/time and the reason or likely future owner.
- `// [PERFORMANCE]`: simple code that may need optimization only after measured slowdown; do not optimize prematurely.
- `// [TEST]`: nearby test coverage reference, usually a test file or test case name.
- `// [NO_COVERAGE]`: intentional coverage gap to follow up later.

## Swarm shape

Use 3-5 lite agents, read-only by default:

1. **API/style scout**: public APIs, names, representative classes, header shape.
2. **Rough-edge scout**: hacks, TODOs, legacy shims, backwards compatibility, duplicated code.
3. **LOC/test scout**: largest files, test gaps, build/CMake risk, perf/lifetime risk.
4. **Design scout**: mental model, user-facing names, concept boundaries.
5. Optional: **domain scout** for rendering, asset pipeline, UI, docs, etc.

## Detached subagents

Use a detached subagent when the user chooses an action during the slide walk and wants review to continue in parallel.

Backends:

- **Default:** Pi via `interactive_shell` dispatch.
- **Fallback/legacy:** OpenCode in a PTY session.

Rules:

- Ask the parent/user first whether the subagent may edit directly, plan only, or use a worktree.
- Parent decides scope, then tells the child exactly what to do.
- Prefer small edits in the active/current worktree when the user says the change is small.
- Use Pi dispatch when `interactive_shell` is available; use OpenCode PTY only when Pi dispatch is not available or the user asks for OpenCode.
- Do not leave sessions running after the result is collected.
- Do not let the child commit or push unless the user explicitly asks.

### Proven detached loop

Use this loop when the user picks “fix in background”:

1. Parent records the slide decision.
2. Parent spawns a Pi dispatch subagent with a large contextual prompt.
3. Child edits only the named files and does not commit.
4. Parent continues the slide walk while the child works.
5. On completion notification, parent reviews the child output and diff.
6. Parent summarizes and asks whether to keep/commit/push.

Example Pi dispatch shape:

```text
interactive_shell:
  spawn={ agent: "pi", prompt: "<large contextual prompt>" }
  mode="dispatch"
  cwd="<target worktree>"
  reason="Walk Review Slide N Edit"
```

Use `background=true` only when a headless session is better than an overlay. Prefer normal dispatch so the user can watch or take over.

Fallback OpenCode PTY shape:

```text
pty_spawn:
  command="opencode"
  args=["run", "<large contextual prompt>"]
  workdir="<target worktree>"
  title="Walk Review Slide N Edit"
  notifyOnExit=true
```

For the fallback, read full output on `<pty_exited>`, then clean up with `pty_kill cleanup=true`.

### Detached prompt rules

Give the child a large prompt so it does not waste time rediscovering context:

- repo/worktree path, branch, PR, and user decision
- exact files to inspect/edit
- relevant snippets or raw file contents
- expected output shape
- verification command preference
- explicit limits: no unrelated cleanup, no commit, no push
- if editing in a PR worktree: remind the child that parent will commit/push later

Optional handoff file:

- Save detailed prompts or context under `notes/handoff/<topic>/<task>.ho.md`.
- Link or summarize the handoff in the PTY prompt.
- Use handoff docs when the prompt is large, reused, or worth auditing later.

### Child prompt template

~~~text
You are a detached subagent helping a parent agent during a walk-review.
Worktree: <absolute path>
Branch: <branch>
PR: <number/url>
User decision for Slide <N>: <A/B/etc and meaning>.

Goal:
- <small edit or tag request>

Context:
- <why this came up>
- <style decision or prior slide outcome>

Likely files:
- <path 1>
- <path 2>

Current relevant code:
```cpp
<snippet>
```

Desired shape:
```cpp
<snippet>
```

Constraints:
- Smallest safe edit.
- No unrelated cleanup.
- Do not commit or push.
- Keep comments short and useful.

Verification:
- Search for old names/tags if relevant.
- Run git diff --stat.

Return:
DONE or BLOCKED
Changed files:
Verification:
Notes:
~~~

## Review categories

- **Human choice**: one clear decision with options.
- **Mass-apply style**: style seen once that may need repo-wide consistency.
- **Legacy/compat**: shims, forwarding headers, deprecated paths, migration debt.
- **Rough edge**: magic constants, placeholders, duplicated assignments, half-built API.
- **Large files**: high LOC or large churn that deserves focused review.
- **Tests**: missing invariant, integration seam, regression risk.
- **Layering**: dependency arrows, ownership boundaries, module seams.
- **Performance**: simple hot-path candidates to measure later; mark with `[PERFORMANCE]`, but keep code simple until slowdown appears.
- **Comments**: sparse files, non-obvious invariants, shader/vendor/layout details.

## Output format

Present findings one at a time as short slides:

~~~markdown
## Slide 1/N — Short title

**File:**
`path/to/file.cpp`

**Tag candidate:**
`// [REVIEW_ME]`

### Snippet

```cpp
// <= 10 lines
```

### Why this matters

- one short bullet

### Decision

A. Fix now
B. Tag with // [REVIEW_ME]
C. Defer with // [DEFER yyyy-mm-dd HH:MM]
D. Skip / revisit later
~~~

Only show the next slide after the user answers, unless they ask for all slides.

Default slide length: about 25-35 short lines total. Include a small diagram or mental model when it clarifies the decision.

Render slides as Markdown with headings, bold labels, fenced snippets, and lettered choices.

When helpful, expand a slide with:

- **What I see**: short mental model or tiny diagram.
- **Likely intent**: possible reasons the code is shaped this way.
- **Proposed small fix**: before/after snippet.
- **My vote**: one short recommendation.

For summaries, keep it concise:

```text
Queue:
1. file:line — // [REVIEW_ME] — decision? A/B/C/D
2. file:line — // [SAMPLE] — keep/apply/change/skip?

Choices for you:
A. Start slide walk
B. Show all snippets
C. Edit tags now
```

## Process

1. Get PR scope: branch, base, files, diff stats.
2. Launch lite scouts with narrow prompts.
3. Merge duplicate findings.
4. Present 5-10 top items only as a queue.
5. Walk one slide at a time with a multiple-choice prompt.
6. If approved, either:
   - add minimal `// [REVIEW_ME]` / `// [SAMPLE]` comments, or
   - spawn a detached subagent for a small edit while the slide walk continues.
7. When a detached subagent exits, read the result, summarize it, and ask whether to keep, adjust, or revert.
8. After several fixes, run a quick style pass for comments and tags.
9. Add `[TEST]` and `[NO_COVERAGE]` tags sparingly near APIs/seams.
10. Update this skill when a new useful category repeats.

## Example slide queue from RenderKit v0

These are useful examples to recreate the flow:

1. `capsule(start, end, ...)` ignored `end` → changed API to `capsule(center, halfHeight, ...)`.
2. `GameApp` assigned camera twice → made `RenderFrame` the single camera source.
3. `RenderKit` included `SceneKit/debug` → `[DEFER yyyy-mm-dd HH:MM]` until debug types move to a kit.
4. `outFrame` naming spread risk → renamed to `renderFrame`.
5. SceneKit forwarding headers → `[SAMPLE]` migration pattern.
6. `wire_box` / `wire_sphere` casing → renamed to `wireBox` / `wireSphere`.
7. linear `RenderFrame::pass()` lookup → `[PERFORMANCE]`, no premature optimization.
8. `RenderPassItems` naming → renamed to `RenderPassBucket`.
9. hardcoded bgfx shader params → added `ShaderParams`, `kWhiteTint`, and short slot comment.

After the slide fixes, add light comments:

- `[TEST] test_renderkit.cpp covers ...`
- `[NO_COVERAGE] ... needs bgfx/integration coverage`
- one-line shader/vendor/layout comments where names are not enough

## Rules

- Do not edit code during scouting.
- Prefer exact file paths and line-ish anchors.
- Do not bury the human in exhaustive findings.
- Use tags sparingly; noisy tags lose value.
- When deferring, include `[DEFER]` plus the current local date/time.
- Prefer `[PERFORMANCE]` over premature optimization when the current simple code is acceptable.
- Use `[TEST]` for real nearby coverage and `[NO_COVERAGE]` for follow-up gaps; do not over-tag every function.
- Prefer comments that state the decision needed, not a vague warning.
- When the user tunes slide length, preserve that preference in this skill.
