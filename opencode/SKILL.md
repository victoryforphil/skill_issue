---
name: opencode
description: >
  Expert knowledge of OpenCode (the AI coding agent). Load when working with
  OpenCode CLI/TUI, configuration, agents, permissions, providers, themes, or
  session workflows.
---

# OpenCode — Expert Reference

> Open source AI coding agent with a terminal-first TUI, headless server mode, and configurable agents.

**Docs:** https://opencode.ai/docs  
**Version captured:** 2026-04-22

---

## Overview

OpenCode is a coding agent with three main surfaces:

- **TUI** for interactive sessions in a terminal
- **CLI** for non-interactive runs and automation
- **Headless server / web** modes for remote or browser-based access

Use it for code exploration, planning, file edits, shell commands, custom agents,
provider setup, and shared sessions.

---

## Core Workflows

### Start a session
```bash
opencode
opencode /path/to/project
```

### Run non-interactively
```bash
opencode run "Explain this module"
```

### Attach / serve / web
```bash
opencode serve
opencode web
opencode attach http://localhost:4096
```

### Reference files and shell output
- `@path/to/file` inserts file contents into the prompt.
- `!command` injects shell output into the prompt.
- `/command` runs a built-in or custom slash command.

---

## Config Hierarchy

OpenCode merges config from multiple places instead of replacing it.

### Precedence
From lowest to highest:
1. Remote config from `.well-known/opencode`
2. Global config: `~/.config/opencode/opencode.json`
3. `OPENCODE_CONFIG`
4. Project config: `opencode.json`
5. `.opencode/` directories
6. `OPENCODE_CONFIG_CONTENT`
7. Managed config files
8. macOS managed preferences / MDM

### Key files
- `opencode.json` — runtime/server config
- `tui.json` — TUI config
- `.opencode/agents/` — Markdown agents
- `.opencode/commands/` — custom commands
- `.opencode/themes/` — custom themes
- `.opencode/plugins/` — plugins
- `~/.local/share/opencode/auth.json` — stored credentials

### Important defaults and caveats
- `tools` is deprecated; use `permission`.
- `default_agent` must be a primary agent.
- `snapshot` is on by default and can be expensive in large repos.
- `share` defaults to manual mode.

---

## Agents

OpenCode has:
- **primary agents** — the main assistants you cycle through with `Tab`
- **subagents** — specialized assistants invoked automatically or with `@`

Built-ins:
- `build` — default primary agent with full tools
- `plan` — primary planning agent with restricted edits/bash
- `general` — flexible subagent
- `explore` — read-only subagent

### Agent definition sources
- JSON config under `agent`
- Markdown agents in `~/.config/opencode/agents/` or `.opencode/agents/`

### Useful agent fields
- `description`
- `mode`
- `model`
- `prompt`
- `permission`
- `hidden`
- `temperature`
- `top_p`
- `steps`
- `color`

### Agent gotchas
- `tools` on agents is legacy.
- `hidden: true` only hides a subagent from autocomplete.
- `permission.task` controls which subagents a primary agent may invoke.
- Providers can receive extra model-specific options through agent config.

---

## Permissions and Tools

### Permission actions
- `allow`
- `ask`
- `deny`

### Practical notes
- Most permissions are permissive by default.
- `external_directory` must be allowed for paths outside the workspace.
- `doom_loop` is a safety guard for repeated identical tool calls.
- `read` is usually allowed, but `.env` files are commonly denied.

### Common tools
- `bash`
- `read`
- `edit`
- `write`
- `grep`
- `glob`
- `apply_patch`
- `skill`
- `todowrite`
- `webfetch`
- `websearch`
- `question`
- `lsp`

### Rule of thumb
- Use `permission` for new setups.
- Keep `tools` only for backwards compatibility.

---

## CLI / TUI Cheatsheet

### Built-in slash commands
- `/connect`
- `/init`
- `/models`
- `/sessions`
- `/themes`
- `/share`
- `/undo`
- `/redo`
- `/compact`
- `/details`
- `/editor`
- `/help`

### Useful CLI commands
- `opencode models [provider]`
- `opencode auth login|list|logout`
- `opencode session list`
- `opencode stats`
- `opencode export`
- `opencode import`
- `opencode upgrade`
- `opencode uninstall`

### TUI notes
- Default leader key: `ctrl+x`
- TUI settings live in `tui.json`
- `OPENCODE_TUI_CONFIG` points at a custom TUI config file
- `COLORTERM=truecolor` is important for accurate theme rendering

---

## Providers and Models

### Basic flow
1. Run `/connect`
2. Add credentials
3. Run `/models`
4. Use `provider/model` IDs in config

### Zen
OpenCode Zen is optional and uses `opencode/<model-id>` IDs.

### Gotchas
- Credentials are stored separately from project config.
- Provider/model availability changes over time.
- `small_model` is useful for lightweight tasks like title generation.

---

## Useful Paths

- Global config: `~/.config/opencode/`
- Credentials: `~/.local/share/opencode/auth.json`
- Project config: `opencode.json`
- TUI config: `tui.json`
- Project agents: `.opencode/agents/`
- Project commands: `.opencode/commands/`
- Project themes: `.opencode/themes/`

---

## Gotchas

- Undo/redo and snapshots rely on Git.
- Large repos may benefit from disabling snapshots.
- Managed config can override user/project settings.
- Some docs refer to multiple auth/share URL variants; check upstream when exact URLs matter.
- Keep `permission` as the primary configuration model for new setups.

---

## Quick Examples

### Plan-style agent
```jsonc
{
  "agent": {
    "plan": {
      "mode": "primary",
      "permission": {
        "bash": "ask",
        "edit": "ask"
      }
    }
  }
}
```

### Custom command
```markdown
---
description: Run tests with coverage
agent: build
---
Run the full test suite with coverage.
```

### Theme config
```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "tokyonight"
}
```
