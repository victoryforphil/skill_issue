---
name: pi-plugin-authoring
description: Author Pi coding-agent plugins/extensions. Use when creating, debugging, packaging, or documenting Pi extensions that subscribe to lifecycle events, register tools/commands/shortcuts, update UI status/widgets, or integrate with external terminal/app protocols such as Warp OSC notifications.
---

# Pi Plugin / Extension Authoring

Use this skill when the user asks to build a Pi plugin, Pi extension, custom Pi tool, slash command, UI integration, status reporter, terminal integration, or package-like add-on.

Pi calls these **extensions** in the docs, even if the user says plugin.

## Required references

Before implementing, inspect the current Pi docs/examples because extension APIs evolve:

- Main extension docs: `/Users/alex/node_modules/@mariozechner/pi-coding-agent/docs/extensions.md`
- Examples: `/Users/alex/node_modules/@mariozechner/pi-coding-agent/examples/extensions/`
- Package distribution docs when needed: `/Users/alex/node_modules/@mariozechner/pi-coding-agent/docs/packages.md`
- TUI details when making custom UI: `/Users/alex/node_modules/@mariozechner/pi-coding-agent/docs/tui.md`

Read the relevant docs and at least one nearby example before coding.

## Extension locations

Pi auto-discovers extensions in:

```text
~/.pi/agent/extensions/*.ts
~/.pi/agent/extensions/*/index.ts
.pi/extensions/*.ts
.pi/extensions/*/index.ts
```

Use project-local `.pi/extensions/<name>/index.ts` for repo-specific behavior.
Use global `~/.pi/agent/extensions/<name>/index.ts` for behavior the user wants everywhere.

Extensions in auto-discovered locations can be reloaded with:

```text
/reload
```

For one-off testing, Pi also supports:

```bash
pi -e ./path/to/extension.ts
```

## Minimal extension skeleton

```ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

export default function myExtension(pi: ExtensionAPI): void {
	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.notify("Extension loaded", "info");
		ctx.ui.setStatus("my-extension", "ready");
	});

	pi.registerCommand("my-command", {
		description: "Run my extension command",
		handler: async (args, ctx) => {
			ctx.ui.notify(`Args: ${args}`, "info");
		},
	});

	pi.registerTool({
		name: "my_tool",
		label: "My Tool",
		description: "Do a small extension task.",
		parameters: Type.Object({
			message: Type.String(),
		}),
		async execute(_toolCallId, params) {
			return {
				content: [{ type: "text", text: `Received: ${params.message}` }],
				details: { ok: true },
			};
		},
	});
}
```

## Common Pi lifecycle hooks

Use these hooks for agent/status integrations:

- `session_start`: session loaded, new, resumed, forked, or reloaded.
- `before_agent_start`: user prompt received before the agent loop. Best place to capture/report prompt submission.
- `agent_start`: agent loop begins.
- `turn_start` / `turn_end`: individual LLM turn boundaries.
- `message_start` / `message_update` / `message_end`: message streaming lifecycle.
- `tool_execution_start`: a tool begins execution.
- `tool_execution_update`: partial tool output.
- `tool_execution_end`: tool finished, with `isError`.
- `tool_call`: before a tool executes; can mutate input or block execution.
- `tool_result`: after a tool executes; can modify returned result.
- `agent_end`: agent loop completed and is waiting again.
- `session_shutdown`: cleanup before quit, reload, switch, new session, or fork.
- `input`: raw user input before skill/template expansion; can continue, transform, or handle.
- `resources_discover`: add skill/prompt/theme paths.
- `model_select`: model changed.

## Useful context/API methods

Inside event handlers, use `ctx`:

- `ctx.cwd`
- `ctx.hasUI`
- `ctx.ui.notify(message, type)`
- `ctx.ui.setStatus(key, text | undefined)`
- `ctx.ui.setWidget(key, lines | undefined, options?)`
- `ctx.ui.setTitle(title)`
- `ctx.ui.confirm(...)`, `ctx.ui.select(...)`, `ctx.ui.input(...)`, `ctx.ui.editor(...)`
- `ctx.sessionManager.getSessionId()`
- `ctx.sessionManager.getSessionFile()`
- `ctx.sessionManager.getEntries()`
- `ctx.sessionManager.getBranch()`
- `ctx.getContextUsage()`
- `ctx.getSystemPrompt()`
- `ctx.isIdle()`
- `ctx.abort()`
- `ctx.shutdown()`

On the `pi` object:

- `pi.on(event, handler)`
- `pi.registerTool(...)`
- `pi.registerCommand(name, options)`
- `pi.registerShortcut(shortcut, options)`
- `pi.registerFlag(name, options)`
- `pi.sendMessage(...)`
- `pi.sendUserMessage(...)`
- `pi.appendEntry(customType, data?)`
- `pi.setSessionName(name)`
- `pi.exec(command, args, options?)`
- `pi.getAllTools()`, `pi.getActiveTools()`, `pi.setActiveTools(names)`

## Working with user interaction

Use `ask_user` before high-stakes architectural decisions or ambiguous requirements. For extension UI inside Pi, use `ctx.ui`.

Rules of thumb:

- Fire-and-forget feedback: `ctx.ui.notify(...)`.
- Persistent footer state: `ctx.ui.setStatus(key, text)`.
- Temporary multi-line context near editor: `ctx.ui.setWidget(key, lines)`.
- Need explicit choice in extension runtime: `ctx.ui.select(...)` / `ctx.ui.confirm(...)`.
- Cleanup status/widgets on `session_shutdown`.

## State persistence

Use `pi.appendEntry(customType, data)` for extension state that should survive reload/resume.

On `session_start`, scan:

```ts
for (const entry of ctx.sessionManager.getEntries()) {
	if (entry.type === "custom" && entry.customType === "my-extension-state") {
		// restore entry.data
	}
}
```

`appendEntry` state does **not** participate in LLM context.

Use `pi.sendMessage({ customType, content, display, details })` if you intentionally want an extension message in session/context.

## Tool authoring notes

- Use `typebox` schemas for tool parameters.
- Add `promptSnippet` and `promptGuidelines` only when the LLM should know the tool exists.
- In `promptGuidelines`, name the tool explicitly; avoid “this tool”.
- Return `{ content: [{ type: "text", text }], details }`.
- Use `onUpdate?.(...)` for long-running progress.
- Use `signal` for abortable work when possible.
- Keep tool names stable and snake_case.

## Command authoring notes

Commands are slash commands. Register:

```ts
pi.registerCommand("name", {
	description: "...",
	handler: async (args, ctx) => {
		// args is raw text after command
	},
});
```

Command contexts have additional safe session-control methods such as:

- `ctx.waitForIdle()`
- `ctx.newSession(...)`
- `ctx.fork(...)`
- `ctx.switchSession(...)`
- `ctx.reload()`

Treat `await ctx.reload(); return;` as terminal for that command handler.

## Terminal / Warp-style OSC integrations

When integrating Pi with terminal/app status surfaces, prefer an explicit protocol module with pure helpers and one small `warpNotify`-style side-effect function.

### Warp cli-agent notification pattern

Warp's OpenCode integration (`warpdotdev/opencode-warp`) uses OSC 777 notifications:

```text
ESC ] 777 ; notify ; warp://cli-agent ; <json payload> BEL
```

In JS/TS:

```ts
const sequence = `\x1b]777;notify;warp://cli-agent;${JSON.stringify(payload)}\x07`;
writeFileSync("/dev/tty", sequence);
```

Important safety behavior:

- Only emit if `process.env.WARP_CLI_AGENT_PROTOCOL_VERSION` is set.
- Optionally add a debug override such as `WARP_PI_AGENT_STATUS_FORCE=1`.
- Write to `/dev/tty`, not normal stdout, so agent output/context is not polluted.
- Catch errors silently or report only via Pi UI; `/dev/tty` may be unavailable in headless/RPC runs.

### Warp payload shape learned from OpenCode plugin

```ts
interface WarpPayloadBase {
	v: number;
	agent: string;
	event: string;
	session_id: string;
	cwd: string;
	project: string;
}
```

Protocol negotiation from OpenCode plugin:

```ts
const PLUGIN_MAX_PROTOCOL_VERSION = 1;
const warpVersion = Number.parseInt(process.env.WARP_CLI_AGENT_PROTOCOL_VERSION || "1", 10);
const v = Number.isNaN(warpVersion) ? PLUGIN_MAX_PROTOCOL_VERSION : Math.min(warpVersion, PLUGIN_MAX_PROTOCOL_VERSION);
```

### Good Pi-to-Warp event mapping

| Pi hook | Warp event |
| --- | --- |
| `session_start` | `session_start` |
| `before_agent_start` | `prompt_submit` |
| `tool_execution_start` | `tool_start` or `question_asked` |
| `tool_execution_end` | `tool_complete` |
| `agent_end` | `stop` |

For attention-needed status, map input-request tools to `question_asked`, for example:

- `ask_user`
- `question`
- `questionnaire`

OpenCode's plugin primarily sends `session_start`, `prompt_submit`, `question_asked`, `tool_complete`, `stop`, `permission_request`, and `permission_replied`. If Warp ignores custom event names, remove or rename extra events such as `tool_start`.

## Example protocol helper module

```ts
import path from "node:path";
import { writeFileSync } from "node:fs";

const MAX_PROTOCOL_VERSION = 1;
const TITLE = "warp://cli-agent";

function protocolVersion(env = process.env): number {
	const n = Number.parseInt(env.WARP_CLI_AGENT_PROTOCOL_VERSION || "1", 10);
	return Number.isNaN(n) ? MAX_PROTOCOL_VERSION : Math.min(n, MAX_PROTOCOL_VERSION);
}

function buildPayload(event: string, sessionId: string, cwd: string, extra: Record<string, unknown> = {}) {
	return JSON.stringify({
		v: protocolVersion(),
		agent: process.env.WARP_PI_AGENT_NAME || "pi",
		event,
		session_id: sessionId,
		cwd,
		project: cwd ? path.basename(cwd) : "",
		...extra,
	});
}

function notifyWarp(body: string): boolean {
	if (!process.env.WARP_CLI_AGENT_PROTOCOL_VERSION && process.env.WARP_PI_AGENT_STATUS_FORCE !== "1") return false;
	try {
		writeFileSync("/dev/tty", `\x1b]777;notify;${TITLE};${body}\x07`);
		return true;
	} catch {
		return false;
	}
}
```

## Validation strategy

Preferred checks:

1. Syntax/bundle check with `esbuild` if available:

```bash
/Users/alex/node_modules/.bin/esbuild .pi/extensions/<name>/index.ts \
  --bundle \
  --platform=node \
  --format=esm \
  --external:@mariozechner/pi-coding-agent \
  --external:@mariozechner/pi-agent-core \
  --external:@mariozechner/pi-ai \
  --external:typebox \
  --outfile=/tmp/<name>-check.mjs
```

2. TypeScript check if the repo has TypeScript installed correctly:

```bash
npm run typecheck
```

Avoid blindly running `npx tsc` in an empty repo: it may fetch the wrong legacy `tsc` package if `typescript` is not installed.

3. Runtime smoke test:

```text
/reload
/<command-name>
```

4. For terminal protocols, test pure helpers separately by bundling the helper module and asserting payload/OSC strings without writing to `/dev/tty`.

## Documentation checklist

For every extension, add a short README near the extension with:

- What it does.
- Where it is installed.
- Event mapping, if lifecycle-based.
- Commands/tools it registers.
- Required environment variables.
- How to reload/test.
- Limitations and known protocol assumptions.

## Implementation checklist

1. Clarify global vs project-local installation.
2. Read current Pi extension docs/examples.
3. Create a small folder with `index.ts` and helper modules.
4. Keep side effects isolated and guarded.
5. Register commands/tools with clear names and descriptions.
6. Add status/widget cleanup on `session_shutdown` when using UI state.
7. Validate with esbuild or TypeScript.
8. Document usage and test commands.
9. Tell the user exactly which files were created and how to reload/test.
