---
hash: "a417c40c4d2a8a435a100c55c417761b6a358abeb0c5cf9d3c1c1b0a701d38be"
name: bun-script
description: Write executable Bun shell scripts using the .sh.ts pattern — TypeScript files with bun shebang, Bun.$ shell, and Bun.spawn for process management.
---

## What I do

- Guide creation of executable TypeScript shell scripts using Bun's built-in shell.
- Define the `.sh.ts` file convention for this repo.
- Cover when to use `Bun.$` vs `Bun.spawn` vs `pty_spawn`.

## When to use me

Load when writing or reviewing any `.sh.ts` script, or when a task needs a shell-script-like workflow in TypeScript.

## The .sh.ts pattern

A **bun-script** is a TypeScript file that uses Bun's shell API, executable via shebang:

```ts
#!/usr/bin/env bun

import { $ } from "bun";

const branch = await $`git rev-parse --abbrev-ref HEAD`.text();
console.log(`Current branch: ${branch.trim()}`);
```

### File conventions

| Convention | Rule |
|---|---|
| Extension | `.sh.ts` — signals "shell script in TypeScript" |
| Shebang | `#!/usr/bin/env bun` — always first line |
| Location | `scripts/` at repo root (or project subdirectory for project-specific scripts) |
| Permissions | `chmod +x script.sh.ts` |
| Run | `./scripts/script.sh.ts` or `bun scripts/script.sh.ts` |

## Bun.$ (shell template tag)

Use for **command execution** — git, file ops, builds, one-shot commands:

```ts
import { $ } from "bun";

// Run and capture output
const hash = await $`git rev-parse HEAD`.text();

// Run quietly (no stdout)
await $`bun run build`.quiet();

// Don't throw on non-zero exit
const { exitCode, stderr } = await $`some-cmd`.nothrow().quiet();

// Set working directory per-command
await $`bun run test`.cwd("./dashboard");

// Pipes, redirection, env vars
await $`echo $FOO | wc -c`.env({ FOO: "bar" });
await $`bun run build 2> errors.txt`;

// Iterate output line-by-line
for await (const line of $`ls`.lines()) {
  console.log(line);
}
```

### Safe interpolation

All interpolated values are **auto-escaped** — no shell injection:

```ts
const userInput = 'file; rm -rf /';
await $`ls ${userInput}`; // Tries to ls a file literally named "file; rm -rf /"
```

### Raw strings (bypass escaping)

```ts
await $`echo ${{ raw: '$(whoami)' }}`;
```

## Bun.spawn (process management)

Use for **long-lived processes** — dev servers, watchers, processes needing stdin/stdout control:

```ts
const proc = Bun.spawn(["bun", "run", "storybook"], {
  cwd: "./dashboard",
  stdout: "pipe",
  stderr: "pipe",
  onExit(proc, exitCode) {
    console.log(`Exited with code ${exitCode}`);
  },
});

// Stream stdout to detect readiness
const reader = proc.stdout.getReader();
const decoder = new TextDecoder();
let buf = "";
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  buf += decoder.decode(value, { stream: true });
  if (buf.includes("Local:")) {
    console.log("Ready!");
    break;
  }
}

// Kill the process
proc.kill("SIGTERM");
await proc.exited;
```

### Graceful shutdown pattern

```ts
const server = Bun.spawn(["bun", "run", "dev"], { stdout: "pipe" });

const cleanup = () => {
  if (!server.killed) server.kill("SIGTERM");
};
process.on("SIGINT", cleanup);
process.on("exit", cleanup);
```

## When to use what

| Scenario | Tool |
|---|---|
| Run a command, capture output | `Bun.$` |
| Chain commands (pipes, redirects) | `Bun.$` |
| Git operations | `Bun.$` |
| Build/test commands | `Bun.$` |
| Start a dev server | `Bun.spawn` or `pty_spawn` |
| Long-running process with I/O control | `Bun.spawn` |
| Interactive terminal (REPL, watch mode) | `pty_spawn` (via opencode) |
| Need stdin/stdout streaming | `Bun.spawn` |

## Template

```ts
#!/usr/bin/env bun

import { $ } from "bun";

const args = process.argv.slice(2);

async function main() {
  // Commands
  await $`echo "Hello from bun-script"`;
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
```
