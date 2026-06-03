---
hash: "0dd612db17f0d08553e30c3a21b30531a4db649b2be475a776a058595d1962aa"
name: agent-plan
description: Run a short interactive plan walkthrough before implementation, using one focused question at a time and concise decision capture.
---

# agent-plan

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `subagent-plan-walkthrough`

# Plan Walkthrough (Concise + Interactive)

Use this before implementation when the user wants to understand, refine, or change the plan.

## Goals
- Help the user understand the plan.
- Focus on the biggest choices first.
- Keep each turn short and easy to scan.
- Invite edits before coding starts.

## Response style
- Keep replies to about 4-8 bullets max.
- Prefer short sections over long prose.
- Do not dump the whole plan unless asked.
- End with 1 clear question or 2-3 small options.

## Default structure
1. **What this plan is trying to do**
2. **Main choices**
3. **Tiny diagram / ASCII flow**
4. **Tradeoff / risk**
5. **Question for the user**

## Walkthrough order
Start with:
1. overall shape
2. biggest architectural decision
3. data / control flow
4. file/module boundaries
5. risky parts
6. implementation order

## Tiny diagram style
Use compact ASCII only, for example:

```text
Input
  -> Parser
  -> Validation
  -> Runtime state
  -> Renderer
```

or

```text
UI
 ├─ View
 ├─ Commands
 └─ State store
```

## Interaction rules
- If the plan is large, explain only one slice per turn.
- Offer alternatives like: "keep / simplify / split / defer".
- If the user seems uncertain, restate the current recommendation in plain language.
- If a choice changes, summarize the updated direction in 2-4 bullets.

## Good ending prompts
- "Want to keep this shape, or simplify it?"
- "Should this stay one module or split in two?"
- "Want me to show the next piece: data flow, files, or risks?"
