---
name: tool-opencode
description: Work with OpenCode CLI/TUI, config, agents, permissions, MCP, plugins, and session workflows in a portable project-neutral way.
---

# tool-opencode

Use this as a generic, project-neutral skill. Active repo guidance (`STYLE.md`, `AGENTS.md`, local examples, and user instructions) overrides these defaults.

## Source: `opencode`

# OpenCode

Use this skill before changing or explaining OpenCode setup in the active repo.

## Read First

- `docs/external/opencode/README.md`
- `docs/external/opencode/mcp-servers.md`
- root `opencode.json`
- `.opencode/agents/README.md` when editing agents

## Config Rules

- Put repo runtime config in root `opencode.json`.
- Keep `.opencode/` for project agents, commands, plugins, themes, and local OpenCode resources.
- Use top-level `mcp` for MCP servers.
- Prefer `permission` for new permission config; `tools` is legacy.
- Keep MCP server names stable and snake_case.

## MCP Pattern

Local stdio MCP server:

```json
{
  "mcp": {
    "server_name": {
      "type": "local",
      "command": ["npx", "-y", "server-package"],
      "enabled": true
    }
  }
}
```

Remote MCP server:

```json
{
  "mcp": {
    "server_name": {
      "type": "remote",
      "url": "https://example.com/mcp",
      "enabled": true,
      "oauth": false
    }
  }
}
```

## Working Rules

- Start from local config and scraped docs before web research.
- Avoid broad agent rewrites unless the user asks.
- Verify JSON after editing config.
- If an MCP is high-risk, document the risk near the config or in `docs/external/`.
