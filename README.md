# VFP Agent Skills

A curated collection of 72 agent skills for OpenCode, Claude Code, Codex, Cursor, and other compatible coding agents.

## Install

### One-liner (recommended)

```bash
npx skills add victoryforphil/skill_issue
```

Or with `add-skill`:

```bash
npx add-skill victoryforphil/skill_issue
```

### Selective install

```bash
# Install specific skills
npx skills add victoryforphil/skill_issue --skill style-core --skill style-git-commit

# List available skills before installing
npx skills add victoryforphil/skill_issue --list
```

### Install globally (all repos)

```bash
npx skills add victoryforphil/skill_issue --global
```

---

## Skills Index

### Style & Review

| Skill | Description |
|-------|-------------|
| `style-core` | Repo-wide style conventions: small LOC, pragmatic DRY, concise comments |
| `style-cpp` | C/C++ conventions for firmware and flight code |
| `style-git-commit` | Loki-style git commit conventions |
| `style-docs` | Documentation style guidelines |
| `style-feedback` | Capture and persist new style conventions as skills |
| `style-guide` | Applies STYLE.md conventions during implementation |
| `writing-guidelines` | Vercel writing guidelines compliance checker |
| `review-style-core` | Code review checkpoints against style pillars |
| `review-core` | General code review guidance |
| `review-dry` | Review for duplication and abstraction overuse |
| `review-comments` | Review for comment quality and noise |
| `review-shape` | Review for function/file shape and organization |
| `review-tests` | Review for test quality and coverage |
| `thermo-nuclear-code-quality-review` | Extremely strict maintainability review for abstraction quality, giant files, and spaghetti-condition growth |

### Languages & Frameworks

| Skill | Description |
|-------|-------------|
| `pro-zephyr` | Zephyr RTOS expert reference (build, devicetree, Kconfig, modules) |
| `pro-rerun` | Rerun visualization SDK expert reference |
| `pro-rerun-cli` | Rerun CLI (`rerun` binary) expert reference |
| `pro-react-three-map` | react-three-map with Mapbox/R3F integration |
| `bun-script` | Bun `.sh.ts` executable shell script patterns |
| `cpp-cmake` | C++ with CMake best practices |
| `cpp-gtest` | GoogleTest unit testing patterns |
| `rust_lint` | Rust linting and code quality |
| `rust-test-nextest` | Rust testing with nextest |
| `schema-flatbuffers` | FlatBuffers schema design and evolution |
| `flatbuffers-schema-maker` | FlatBuffers schema creation and CMake integration |
| `generic-flatbuffers-schema-maker` | Generic FlatBuffers schema skill |
| `geojson` | GeoJSON format reference |

### Developer Tooling

| Skill | Description |
|-------|-------------|
| `opencode` | OpenCode CLI/TUI/config expert reference |
| `gh-stack` | GitHub stacked PRs management via `gh stack` |
| `pi-worktree-status` | Pi workspace channel for worktree coordination |
| `pi-plugin-authoring` | Author Pi coding-agent plugins/extensions |
| `skill-scraper` | Scrape docs.rs into OpenCode skills |
| `skill-authoring` | Author new skills for the ecosystem |
| `docs-scraper` | Scrape technical docs into local reference notes |
| `docs-scraping` | Web documentation scraping patterns |
| `find-skills` | Discover and install skills from the ecosystem |
| `use-railway` | Railway infrastructure CLI and MCP reference |
| `gitter-commit` | Alternative git commit workflow |
| `gha-babysit` | GitHub Actions maintenance and troubleshooting |

### Workflow & Agents

| Skill | Description |
|-------|-------------|
| `agent-core` | Core agent patterns and principles |
| `agent-plan` | Planning agent patterns |
| `agent-review` | Agent review and feedback patterns |
| `agent-handoff` | Handoff patterns between agents |
| `agent-fanout` | Parallel agent fanout patterns |
| `script-authoring` | Author shell/automation scripts |
| `devcontainer-workflows` | Devcontainer setup and workflow patterns |
| `research` | Research and investigation workflows |
| `tool-opencode` | OpenCode-specific tool patterns |

### Project-Specific

| Skill | Description |
|-------|-------------|
| `firmware-tmux-test-cycle` | ESP32 UWB hardware test with tmux |
| `portal-kidcad` | Portal PCB editor monorepo setup and dev |
| `install-vfp-tuikit-skills` | Install VFP TUI kit skills |
| `vfp-tuikit` | VFP TUI kit patterns |
| `tui-kit` | TUI kit reference |
| `vfp-style-git` | VFP-style git commit guidance |
| `design-docs` | Write and maintain design docs in `docs/designs/` |
| `geojson` | GeoJSON format reference |
| `thread-scribe` | Thread/messaging patterns |
| `dax-routing` | DAX routing patterns |
| `pty-backend` | PTY backend patterns |
| `designer` | Design patterns |
| `reflect` | Reflection patterns |
| `reflect-constant` | Constant reflection patterns |
| `builder` | Builder pattern references |
| `proto-install` | Protocol/ protobuf installation patterns |
| `spatial-layout-iteration` | Spatial layout iteration patterns |
| `tsc-fix` | TypeScript compiler fix patterns |
| `scrape-routing` | Web scraping and routing patterns |
| `opencode-migration` | OpenCode migration guidance |
| `pluginize-opencode` | Turn functionality into OpenCode plugins |
| `gitter-commit` | Git commit workflow |
| `feedback` | Feedback capture patterns |
| `git-commit` | Git commit patterns |
| `git-pr` | Git PR creation and management |

---

## <details><summary>Agent Prompt Reference (collapse/expand)</summary>

Add this to your agent's system prompt or `AGENTS.md` to surface the full skill library:

```
## Available Skills

This repo has skills in `.agents/skills/` (project) and `~/.agents/skills/` (global).
Load with: `skill({ name: "skill-name" })`

### Style & Review
- style-core, style-cpp, style-git-commit, style-docs, style-feedback, style-guide
- writing-guidelines, review-style-core, review-core, review-dry, review-comments, review-shape, review-tests
- thermo-nuclear-code-quality-review

### Languages & Frameworks
- pro-zephyr (Zephyr RTOS), pro-rerun, pro-rerun-cli, pro-react-three-map
- bun-script, cpp-cmake, cpp-gtest, rust_lint, rust-test-nextest
- schema-flatbuffers, flatbuffers-schema-maker, generic-flatbuffers-schema-maker, geojson

### Developer Tooling
- opencode (OpenCode CLI/TUI reference), gh-stack (GitHub stacked PRs)
- pi-worktree-status, pi-plugin-authoring
- skill-scraper (docs.rs → skill), skill-authoring, find-skills
- docs-scraper, docs-scraping, use-railway, gitter-commit, gha-babysit

### Workflow & Agents
- agent-core, agent-plan, agent-review, agent-handoff, agent-fanout
- script-authoring, devcontainer-workflows, research, tool-opencode

### Project-Specific
- firmware-tmux-test-cycle (ESP32 UWB hardware tests)
- portal-kidcad (Portal PCB editor dev)
- install-vfp-tuikit-skills, vfp-tuikit, tui-kit
- vfp-style-git, design-docs
- builder, designer, reflect, reflect-constant, proto-install
- tsc-fix, geojson, thread-scribe, dax-routing, pty-backend
- spatial-layout-iteration, scrape-routing, opencode-migration, pluginize-opencode
- git-commit, git-pr, feedback

When unsure which skill to load, use `find-skills` to search.
```

</details>

## Skill Format

Each skill is a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: One-liner description of when to load this skill
---
```

Skills are discovered by the agent runtime in these locations:
- `.agents/skills/<name>/SKILL.md` (project-local)
- `~/.agents/skills/<name>/SKILL.md` (global/user-level)
- `.opencode/skills/<name>/SKILL.md` (OpenCode format)
- `.claude/skills/<name>/SKILL.md` (Claude-compatible)

## Sources

Skills were curated from:
- `~/repos/andreas/loki/.agents/skills/` — Loki drone firmware project
- `~/.agents/skills/` — Alex's global skill collection
- `~/repos/vfp/` — Various VFP projects (real_agi_i_promise, dark-factory, chappie, tinyverse, etc.)