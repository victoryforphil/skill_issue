---
hash: "39f94e5bea4897f71af1df8f78f3d5b284da3af285677797f75da3f5eaaaf73f"
name: pluginize-opencode
description: Convert native OpenCode assets into pluginized files (.agent.md, .cmd.md, .skill.md, .tool.ts|js, .rule.md).
---

## What I do

- Convert existing OpenCode assets into plugin-authored file formats.
- Keep behavior equivalent while normalizing filenames and supported metadata.
- Produce a clear migration report with preserved, changed, and dropped fields.

## When to use me

Use this when migrating or packaging OpenCode assets for plugin distribution, including:

- agents
- commands
- skills
- tools
- rules

## Inputs

Provide:

- asset type (`agent`, `command`, `skill`, `tool`, `rule`)
- source path
- target root (optional)

## Mapping

- `.opencode/agents/<name>.md` -> `agents/<name>.agent.md`
- `.opencode/commands/<name>.md` -> `commands/<name>.cmd.md`
- `.opencode/skills/<name>/SKILL.md` -> `skills/<name>.skill.md`
- `.opencode/tools/<name>.ts|js` -> `tools/<name>.tool.ts|js`
- `AGENTS.md` -> `rules/project.rule.md`

## Guardrails

- Preserve runtime behavior first; keep stylistic changes minimal.
- Do not invent unsupported frontmatter fields.
- If a field is dropped, list it explicitly in output.
- Keep precedence assumptions explicit: `project > global > plugin defaults`.

## Output contract

Return:

- Source -> target path(s)
- Validation results
- Preserved/normalized/dropped fields
- Follow-up actions if manual cleanup is needed

Validation default for agents:

- Run `bun scripts/agent_sandbox.sh.ts test` to verify registration in reefer before handoff.

Reference:

- `kits/dax/opencode_pluginization_guide.md`
