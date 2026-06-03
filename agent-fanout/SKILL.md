---
name: agent-fanout
description: Use scout, research, and bulk worker fanout patterns for broad recon, parallel investigation, and synthesis without losing control of decisions.
---

# agent-fanout

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `subagent-bulk-scout-intern`

# Bulk Scout/Intern Skill

Use for large-surface discovery where many tiny checks are faster in parallel.

Named pattern: `local-recon-fanout`.

## Scope rules
`agent-lite` is the mini-model local agent. Use it only for:
- read-only scans
- extraction/classification
- pattern/count checks
- short evidence snapshots

Do NOT use `agent-lite` for:
- architecture choices
- final code review verdicts
- broad refactor execution
- web/doc research synthesis

## Swarm template
```json
{
  "tasks": [
    { "agent": "agent-lite", "task": "List all serialization entry points under engine/" },
    { "agent": "agent-lite", "task": "List all manual memory management hotspots under engine/" },
    { "agent": "agent-lite", "task": "Map parser-related error handling paths" },
    { "agent": "agent-lite", "task": "Find tests that exercise parser failures" }
  ],
  "concurrency": 4
}
```

Default to 3-6 child tasks when the surface really splits; hard cap 10.

## Fan-in pattern
After swarm output, run one heavier synthesis step:
- `agent-lite` for implementation plan
- `agent-lite` for quality/risk assessment
- `agent-lite` for web/doc synthesis after parallel fan-out

This wider shape is `scatter-gather`: many narrow workers, one synthesizer.

## Prompting tips for mini agents
- Specify directory boundaries.
- Specify exact output schema.
- Ask for file paths + line ranges.
- Ask for confidence and missing data.

## Parent context control
- Keep only consolidated findings in parent chat.
- Store full evidence in files when needed.
- Avoid replaying full parallel outputs unless required.

---

## Source: `subagent-kickoff-quick`

# Subagent Kickoff (Quick)

Use this at the start of a new task/project.

## Behavior
- Be fast and minimal.
- Ask the user first whether to use subagents.
- If needed, run one narrow `agent-lite` recon before deciding.

## Ask this first
"Do you want this done with subagents for speed, or single-agent for simplicity?"

## Mini flow
```text
Task start
 ├─ User says single-agent -> do direct
 └─ User open to subagents
    ├─ Scope unclear -> run agent-lite micro-recon
    └─ Scope clear
       ├─ One-step -> single specialist
       ├─ Multi-stage -> chain
       └─ Many independent checks -> parallel + fan-in
```

## Recon prompt (if unclear)
Use one quick `agent-lite` task like:
- "Map files + risk hotspots for <task> in <=10 bullets with line refs."

Then pick the smallest viable pattern and proceed.

---

## Source: `subagent-research-review`

# Research + Review Skill

Use when requirements depend on external docs/APIs, or when high-confidence review is required.

## Research-first pipeline
1. Parallel `agent-lite` web search tasks gather narrow evidence by angle.
2. Optional local `agent-lite` maps integration points into `context.md`.
3. `agent-lite` synthesizes into `research.md`.
4. `agent-lite` creates `plan.md` using both files.
5. `agent-lite` implements.
6. `agent-lite` validates behavior and regressions.

## Named pattern: `parallel-angle-research`
Use this when research has multiple independent angles.

Typical angle set:
- official docs/specs
- practical examples
- alternatives/tradeoffs
- recent issues/risks
- optional local integration scout

## Suggested chain
```json
{
  "chain": [
    {
      "parallel": [
        { "agent": "agent-lite", "task": "Research official docs/spec angle for {task}" },
        { "agent": "agent-lite", "task": "Research practical examples angle for {task}" },
        { "agent": "agent-lite", "task": "Research alternatives/tradeoffs angle for {task}" },
        { "agent": "agent-lite", "task": "Research recent risks/issues angle for {task}" },
        { "agent": "agent-lite", "task": "Map local code touchpoints for {task}", "output": "context.md" }
      ],
      "concurrency": 4
    },
    { "agent": "agent-lite", "task": "Synthesize the parallel findings into one recommendation for {task}", "output": "research.md" },
    { "agent": "agent-lite", "task": "Create implementation plan", "reads": ["research.md", "context.md"], "output": "plan.md" },
    { "agent": "agent-lite", "task": "Implement plan", "reads": ["plan.md", "context.md", "research.md"] },
    { "agent": "agent-lite", "task": "Review correctness + regressions", "reads": ["plan.md", "progress.md"] }
  ]
}
```

## Reviewer delegation guidance
Reviewer may spawn narrow checks using mini agents:
- `agent-lite`: enumerate potential hotspots, TODOs, duplicated logic
- `agent-lite`: verify local call paths and assumptions
- `agent-lite`: verify external doc/API assumptions

Reviewer should usually fan out 2-4 checks, then own the final judgment and synthesis.

This pattern is `review-fanout`.

## Output discipline
- Research: citations and decision-ready summary.
- Review: concrete issues only, with evidence.
- Prefer 3-6 research children by default; hard cap 10.
- Parent summary: 5-10 bullets max + paths to artifacts.
