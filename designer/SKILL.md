---
name: designer
description: Guidance for using the design agents in OpenCode.
---

# Designer agent guidance

## Use this when
- You need UI, interaction, or product design exploration.
- You want quick options before implementation.
- You need one agent to research and another to synthesize.

## Agent split
- **agent-design-lite**: quick exploration, references, tradeoffs, and short recommendations.
- **agent-design-heavy**: larger design decisions and synthesis. Use sparingly.
- **agent-design-staff**: rare, highest-cost final calls. Use very sparingly.

## Default pattern
- Use a stronger design agent first when you need the initial creative spark: visual direction, component look/feel, layout options, UX framing, or a coded styling plan.
- After that first direction-setting pass, prefer cheaper agents for iteration, refinement, and implementation follow-through.
- Treat the expensive pass as the concept setter, not the whole workflow.

## Cost guardrails
- Default to `agent-design-lite` first.
- Aim to keep the full session's design-agent spend in the **$1-5 total** range.
- Use `agent-design-heavy` only for high-level synthesis or one-shot direction setting.
- If a single design-agent invocation starts landing in roughly the **$2-5** range, treat that as a stop signal: do not fan out more expensive design calls by default.
- Prefer no more than **1 heavy/staff** design call per session unless the user explicitly wants to spend more.
- Prefer `agent-design-staff` only with explicit justification, and usually only once.
- After each design-agent call, check the returned usage/cost and tighten the plan if spend is climbing.

## When to start with a stronger model
- Start with `agent-design-heavy` when the main problem is "what should this look like?" rather than "how do I implement the chosen thing?"
- Consider `agent-design-staff` for rare, high-leverage concept work where a better first idea can save multiple iteration rounds.
- Good examples:
  - defining a new tool shell or panel layout
  - choosing component visual language
  - planning the code structure needed to achieve a specific UI feel
  - early UX direction before implementation begins

## Workflow
1. For routine or low-risk design questions, use `agent-design-lite` to gather options and constraints.
2. For high-leverage early concept work, use `agent-design-heavy` first to set direction.
3. Use `agent-design-staff` only for the rarest and highest-value initial spark or final tie-breaker.
4. Hand off refinement, implementation, and follow-on iteration to cheaper agents once the direction is set.
5. Re-use stronger design agents only when the direction itself is failing, not for normal polish loops.
6. Avoid parallel heavy/staff design calls unless the user explicitly approves the spend.
7. If actual usage suggests the session could exceed about **$5 total**, pause and ask before continuing with more premium design passes.

## Prompt quality rule
- Front-load as much local context as possible before calling a design agent.
- Prefer giving it:
  - exact file paths
  - short copied snippets or summaries from the relevant files
  - the current UI structure in bullets
  - ASCII layout sketches when layout is the question
  - explicit constraints, user preferences, and already-locked decisions
- Use the design agent for design judgment and synthesis, not for avoidable file hunting.
