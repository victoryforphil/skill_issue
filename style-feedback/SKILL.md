---
hash: "1374e9628560bddf1a99a6805250923099a1a42f7ab5b5dc3ad66fe2abc23413"
name: style-feedback
description: Capture feedback about code style, patterns, or conventions and persist it as a style-* skill in .agents/skills/. Load when the user gives style feedback or asks to create/update a style skill.
---

# Style Feedback

When the user gives feedback about code conventions, structure, naming, patterns, or project style, use this skill to persist that knowledge as a reusable `style-*` skill so agents can apply it in future sessions.

## Workflow

1. **Understand the feedback.** Clarify with the user if needed. Is this a new convention or a change to an existing one?

2. **Read existing style skills.** Check `.agents/skills/style-*/SKILL.md` to see if any existing skill already covers the topic.

3. **Create or update the skill:**
   - If the feedback adds to an existing skill → update it (edit the SKILL.md).
   - If the feedback introduces something new → create `.agents/skills/style-{topic}/SKILL.md`.

4. **Write the skill content.** Every style skill must include:
   - **Frontmatter** with `name` (`style-{topic}`) and `description`.
   - **What the convention is** — clear dos and don'ts.
   - **Concrete examples** — code snippets showing the right and wrong way.
   - **Rationale** — why this convention exists (readability, consistency, framework best practice, etc).
   - **File patterns** — which files this applies to (e.g. `src/**/*.ts`, `src/modules/**/*.routes.ts`).

5. **Apply to source code.** After creating/updating the skill, check if any existing source files violate the new convention. If so, fix them. Run tests afterward.

## Guidelines

- Skill names must match regex `^[a-z0-9]+(-[a-z0-9]+)*$`, 1-64 chars.
- Descriptions must be 1-1024 chars, specific enough for agents to choose correctly.
- Keep skills actionable — an agent should be able to load the skill and immediately know what to do.
- Link to external docs (Elysia docs, PocketBase docs, etc.) where relevant.
- If the feedback is about something that can't be captured as a skill (e.g. ephemeral or task-specific), explain why and suggest a different approach.

## Agent learning note

When you (the agent) discover a pattern or convention during your work that isn't documented in any existing `style-*` skill, create or update one proactively. Conventions should be written down the first time you encounter them, not accumulated as tribal knowledge.
