---
hash: "5fa36dacd971f2893e185dabf255762c4072e5f0d0f33af2a86e7925e05f59ad"
name: portal-kidcad
description: Setup, refresh, and run the Portal PCB editor monorepo locally, with separate instructions for first clone, after fetching changes, and every normal dev session.
---

# Portal KidCAD / Portal PCB Editor

Use this skill when working in the repository at:

`/Users/alex/repos/hices/portal_eda/portal_kidcad`

## What this project is

- Monorepo managed by `pnpm` workspaces + `turbo`
- Frontend: React 19 + Vite (`apps/web`)
- Backend: Hono (`apps/server`)
- Shared package: `packages/core`
- CLI: `apps/cli`

## Prerequisites

- Node.js 20+
- `pnpm` **10.17.1** (pinned in root `package.json`)
- Optional: Docker, if Redis caching is desired
- Optional: Anthropic API key for local AI chat

If `pnpm` is missing in this environment, install the pinned version with:

```bash
proto install pnpm 10.17.1
```

## First time setup (fresh clone)

Preferred command from repo root:

```bash
cd /Users/alex/repos/hices/portal_eda/portal_kidcad
pnpm setup
```

What `pnpm setup` does:

```bash
proto install pnpm 10.17.1   # if needed
pnpm install
cp apps/server/.env.example apps/server/.env   # only if missing
```

Then edit `apps/server/.env`:

- Set `ANTHROPIC_API_KEY` if you want local AI chat/server features
- Leave Redis vars off unless you explicitly want local Redis

### Fastest way to start using the app

If you do **not** want to configure a local API key yet, run only the frontend against the hosted backend:

```bash
pnpm dev:remote
```

### Full local dev

```bash
pnpm dev
```

This starts:

- frontend at `http://localhost:5173`
- server at `http://localhost:3001`

## After fetching / pulling changes

Preferred command from repo root:

```bash
cd /Users/alex/repos/hices/portal_eda/portal_kidcad
pnpm setup:refresh
```

What that does:

```bash
pnpm install
```

Then decide if more is needed:

- If `apps/server/.env.example` changed, compare it with your `apps/server/.env` and merge new variables manually.
- If only application code changed, `pnpm install` is usually enough.
- If you want a confidence check after larger changes:

```bash
pnpm typecheck
pnpm build
```

## Every normal dev session

### Preferred full stack local dev

```bash
cd /Users/alex/repos/hices/portal_eda/portal_kidcad
pnpm dev
```

### Frontend only with hosted backend

```bash
pnpm dev:remote
```

### Run workspaces separately

```bash
pnpm --filter @portal/web dev
pnpm --filter @portal/server dev
```

### Helper scripts

```bash
bash scripts/dev.sh local
bash scripts/dev.sh remote
bash scripts/dev.sh web
bash scripts/dev.sh server
bash scripts/setup.sh everytime
```

## Verification / smoke checks

### Local server health

```bash
curl http://localhost:3001/health
```

Expected:

```json
{"ok":true}
```

### Helpful project commands

```bash
pnpm typecheck
pnpm build
pnpm test
pnpm verify
pnpm -s cli --help
pnpm redis:up
pnpm redis:down
```

## Notes and caveats

- The local server can boot without a real `ANTHROPIC_API_KEY`, but AI chat features will not work correctly until a valid key is set.
- The frontend can be used without local server setup via `pnpm dev:remote`.
- Redis helper commands now use the repository's actual `docker-compose.yml` file.
- To open the running frontend in user Chrome on macOS, use:

```bash
open -a 'Google Chrome' http://127.0.0.1:5173
```

If the dev server is not already running, Chrome will open but the page may show a connection error until Vite starts.

## What I should do when asked to "run this project"

1. Confirm I am in `/Users/alex/repos/hices/portal_eda/portal_kidcad`
2. Ensure pinned `pnpm` is available (`proto install pnpm 10.17.1` if required)
3. On first clone: run `pnpm setup`
4. On fetch/pull: run `pnpm setup:refresh`
5. For quick usage without secrets: run `pnpm dev:remote`
6. For full local dev: run `pnpm dev`
7. Validate with `curl http://localhost:3001/health` and/or opening `http://localhost:5173`
8. If asked to open it in Chrome on macOS, use `open -a 'Google Chrome' http://127.0.0.1:5173`
