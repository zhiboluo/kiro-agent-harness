# Kiro Agent Harness

[![CI](https://github.com/zhiboluo/kiro-agent-harness/actions/workflows/ci.yml/badge.svg)](https://github.com/zhiboluo/kiro-agent-harness/actions/workflows/ci.yml)

A structured agent configuration system for Kiro CLI, implementing the [_SYNTHESIS.md](kiro/spec-docs/_SYNTHESIS.md) blueprint.

**Status:** All 3 phases complete. External review remediated. 170 test assertions passing.

## What This Is

A harness that makes Kiro CLI agents more reliable through:
- **Steering files** — always-loaded behavioral constraints (5 files, 179 lines total)
- **Agent configs** — hub agent + 4 specialized subagents with minimum privilege
- **Skills** — 10 on-demand workflow skills
- **Memory conventions** — cross-session persistence of decisions and patterns (starts empty; your sediment accumulates)

**Good fit:** you work across several projects from a terminal, want consistent agent behavior (security boundaries, evidence-before-done, scope discipline) without re-prompting for it every session, and want decisions to persist across sessions. Less useful if you only use an agent occasionally in one repo — the built-in defaults are fine there.

## Installation

### New machine setup

```bash
# Clone the repo
git clone https://github.com/<your-username>/kiro-agent-harness.git
cd kiro-agent-harness

# Install global harness files to ~/.kiro/
bash kiro/global/install.sh

# Activate this project's workspace agent (generates machine-local config)
cd kiro && bash activate.sh

# Review and customize
vim ~/.kiro/steering/AGENTS.md    # update canary, preferences

# Optionally set harness-default as your default agent
kiro-cli agent set-default harness-default
```

The install script copies steering, agents, skills, and memory to `~/.kiro/`. It skips existing files — use `--force` to overwrite:

```bash
bash kiro/global/install.sh --force
```

Absolute paths in agent configs are updated to match the current user's `$HOME`.

### What gets installed

```
~/.kiro/
├── steering/          # 5 files: AGENTS.md, base-constraints, security, documentation, graphify
├── agents/            # 5 agents: harness-default, worker, reviewer, researcher, planner
│   └── prompts/       # harness-default-prompt.md
├── skills/            # 10 skills: session-memory, context-budget-audit, research-first,
│                      #   project-harness-init, session-handoff, adversarial-review,
│                      #   harness-evolution, skill-effectiveness-eval,
│                      #   dispatching-parallel-agents, verification-before-completion
├── hooks/             # block-credentials.sh — preToolUse guard (exit 2 blocks)
└── memory/            # Empty structure — your decisions/patterns accumulate here
```

### Migrating to another machine

1. Push latest changes: `git push`
2. On new machine: clone + run `install.sh`
3. Update `~/.kiro/steering/AGENTS.md` with machine-specific preferences
4. Install any additional skills not managed by this harness (graphify, etc. — optional external tools; the graphify steering rule degrades gracefully when `graphify-out/` is absent)

### Keeping in sync

When you modify global files in `~/.kiro/`, copy changes back to the repo:

```bash
# Example: updated a steering file
cp ~/.kiro/steering/AGENTS.md kiro/global/steering/
git add -A && git commit -S -m "sync: update AGENTS.md"
git push
```

On other machines, pull and re-install:
```bash
git pull
bash kiro/global/install.sh --force
```

### Upstream & deployment

This repository is the upstream — harness development happens here. Machines consume it:

- Deploy with `bash kiro/global/install.sh` (plus `cd kiro && bash activate.sh` for this project's agent)
- Machine-local state stays on the machine and is never committed back: `~/.kiro/memory/` entries, extra installed skills, `settings/cli.json`, the generated `harness-kiro.json`
- Kiro CLI 3.x note: hooks move from agent-config JSON fields to standalone `.kiro/hooks/*.json` files — run `kiro-cli agent migrate` when upgrading. The bundled `preToolUse` guard uses the 2.x embedded format.

## Quick Start

```bash
# Default agent (harness-default) — works in any project
kiro-cli chat

# This project's agent
cd ~/projects/kiro-agent-harness/kiro
kiro-cli chat --agent harness-kiro

# Scaffold .kiro/ in a new project
> init project

# Trigger skills by keyword
> remember this          # session-memory
> context budget          # context-budget-audit
> adversarial review      # adversarial-review (3-critic parallel)
> evaluate skill          # A/B skill comparison
```

### What it looks like (illustrative)

```text
~$ kiro-cli chat
[your-canary] Ready.

you: how does the build system cache dependencies?
[your-canary] research-first — reading build files first ...
              findings: cache lives in .turbo/, keyed by content hash (turbo.json:14)

you: remember that we use Bun, not npm — stop suggesting npm
[your-canary] session-memory — written to .kiro/memory/decisions/2026-09-28-package-manager.md
              and indexed in .kiro/memory/INDEX.md

you: adversarial review the new retry logic
[your-canary] adversarial-review — dispatching 3 critics in parallel
              (skeptic / security auditor / scope guardian) ...
              verdict: REVISE — 2 issues, see merge report
```

The bracketed prefix is the canary from your `AGENTS.md` — if it ever disappears from a
response, that steering file failed to load and the session needs attention.

## Structure

```
kiro-agent-harness/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── .gitignore
├── .github/workflows/ci.yml       # Ubuntu/macOS matrix + shellcheck
├── kiro/
│   ├── global/                      # Portable harness → deploy to ~/.kiro/
│   │   ├── install.sh               # Deploy script
│   │   ├── steering/                # 5 steering files
│   │   │   ├── AGENTS.md
│   │   │   ├── base-constraints.md
│   │   │   ├── security.md
│   │   │   ├── documentation.md
│   │   │   └── graphify.md
│   │   ├── agents/                  # 5 agent configs
│   │   │   ├── harness-default.json
│   │   │   ├── worker.json
│   │   │   ├── reviewer.json
│   │   │   ├── researcher.json
│   │   │   ├── planner.json
│   │   │   └── prompts/
│   │   │       └── harness-default-prompt.md
│   │   ├── hooks/                   # block-credentials.sh — preToolUse guard
│   │   ├── skills/                  # 10 harness skills
│   │   │   ├── session-memory/
│   │   │   ├── context-budget-audit/
│   │   │   ├── research-first/
│   │   │   ├── project-harness-init/
│   │   │   ├── session-handoff/
│   │   │   ├── adversarial-review/
│   │   │   ├── harness-evolution/
│   │   │   ├── skill-effectiveness-eval/
│   │   │   ├── dispatching-parallel-agents/
│   │   │   └── verification-before-completion/
│   │   └── memory/                  # Empty memory structure (fills as you use it)
│   │       ├── INDEX.md
│   │       ├── decisions/
│   │       └── patterns/
│   ├── templates/                   # Project agent scaffolding
│   │   ├── setup-project.sh         # Scaffold script
│   │   ├── AGENTS.md                # Template workspace AGENTS.md
│   │   └── .kiro/
│   │       ├── agents/
│   │       │   ├── PROJECT_NAME.json
│   │       │   └── prompts/PROJECT_NAME-prompt.md
│   │       ├── steering/product.md
│   │       └── memory/INDEX.md
│   ├── .kiro/                       # This project's workspace config
│   │   ├── agents/
│   │   │   ├── harness-kiro.json.template  # Tracked (REPLACE_WITH_HOME placeholder)
│   │   │   ├── harness-kiro.json           # Generated by activate.sh (gitignored)
│   │   │   └── prompts/harness-kiro-prompt.md
│   │   ├── memory/
│   │   ├── plans/
│   │   └── steering/documentation.md
│   ├── activate.sh                  # Generates harness-kiro.json from template
│   ├── AGENTS.md                    # This project's agent instructions
│   ├── spec-docs/                   # Blueprint (_SYNTHESIS.md)
│   └── tests/                       # 9 repo test scripts + 1 machine audit (170 assertions)
```

**Global harness (installed to ~/.kiro/):**
```
~/.kiro/
├── steering/            # AGENTS.md, base-constraints.md, security.md, documentation.md, graphify.md
├── agents/              # harness-default, worker, reviewer, researcher, planner (+ any you add)
│   └── prompts/         # harness-default-prompt.md
├── skills/              # 10 harness skills + any you add
└── memory/              # your accumulated entries
    ├── INDEX.md
    ├── decisions/
    └── patterns/
```

## Phases Delivered

| Phase | Deliverables | Tests | Date |
|-------|---|---|---|
| 1: Foundation | 2 steering files, 5 agent configs, skill update | 54 assertions | June 2026 |
| 2: Core Skills | session-memory, context-budget-audit, research-first, project-harness-init, session-handoff | 50 assertions | June 2026 |
| 3: Advanced | adversarial-review, harness-evolution, skill-effectiveness-eval, dispatching enhancement, memory dedup | 36 assertions | June 2026 |
| Post-Phase 3 | Synthesis refresh (§11), skill standardization, graphify integration, model updates, memory population | — | Sept 2026 |

## Creating a Custom Agent for a New Project

### Using the setup script (recommended)

```bash
# Scaffold a customized agent for any project
bash kiro/templates/setup-project.sh ~/projects/my-app my-app

# Then customize:
# 1. Edit my-app/AGENTS.md — project context and canary
# 2. Edit my-app/.kiro/steering/product.md — tech stack and conventions
# 3. Edit my-app/.kiro/agents/my-app.json — description and hooks
# 4. Launch: cd my-app && kiro-cli chat --agent my-app
```

The script creates:
```
my-app/
├── AGENTS.md                        # Project instructions (canary auto-generated)
└── .kiro/
    ├── agents/
    │   ├── my-app.json              # Agent config with harness resources wired in
    │   └── prompts/my-app-prompt.md # Agent prompt (editable)
    ├── steering/product.md          # Project tech stack and conventions
    └── memory/INDEX.md              # Empty memory index
```

### Manual setup

Custom agents do NOT inherit from the default agent. Add these resources explicitly:

```json
{
  "name": "my-project-agent",
  "description": "...",
  "prompt": "...",
  "tools": ["*"],
  "resources": [
    "file://AGENTS.md",
    "file:///home/<user>/.kiro/steering/**/*.md",
    "file://.kiro/steering/**/*.md",
    "file://.kiro/memory/INDEX.md",
    "skill://~/.kiro/skills/**/SKILL.md",
    "skill://.kiro/skills/**/SKILL.md"
  ],
  "model": "claude-opus-5"
}
```

### Critical Rules

| Rule | Why |
|------|-----|
| Always include `"file://AGENTS.md"` | NOT auto-loaded for custom agents |
| Use absolute paths for global files: `file:///home/<user>/...` | `file://~` tilde doesn't expand |
| `skill://~` tilde works fine | Only `file://` is affected |
| Kiro workspace root = CWD | NOT the git root — launch chat from the right directory |

### What Loads Automatically vs Explicitly

| Context Source | Default agent | Custom agent (`--agent`) |
|---|---|---|
| `~/.kiro/steering/*.md` | ✅ Auto | ❌ Needs `resources` |
| `.kiro/steering/*.md` | ✅ Auto | ❌ Needs `resources` |
| Workspace `AGENTS.md` | ✅ Auto | ❌ Needs `resources` |
| `~/.kiro/steering/AGENTS.md` | ✅ Auto | ❌ Needs resource glob |
| Global skills | ✅ Auto | ❌ Needs `skill://` resource |
| Hooks | ✅ From default agent JSON | ❌ Only from own agent JSON |

## Available Subagents

| Agent | Role | Tools | Model |
|-------|------|-------|-------|
| `worker` | Implementation | read, write, shell, code | sonnet-4.6 |
| `reviewer` | Skeptical code review (read-only) | read, code, shell | sonnet-4.6 |
| `researcher` | Exploration (read-only) | read, code, shell | sonnet-4.6 |
| `planner` | Task decomposition (read-only) | read, code, shell | sonnet-4.6 |

## Skills (10 harness skills)

| Skill | Trigger Keywords |
|-------|---|
| `session-memory` | "remember this", "save decision", "wrap up" |
| `context-budget-audit` | "context budget", "token usage", "what is loaded" |
| `research-first` | "how does this work", "is there already" |
| `project-harness-init` | "init project", "setup kiro", "scaffold" |
| `session-handoff` | "end session", "wrap up", "continue later" |
| `adversarial-review` | "adversarial review", "critique this plan", "red team" |
| `harness-evolution` | "improve harness", "evolve skills", "what keeps failing" |
| `skill-effectiveness-eval` | "evaluate skill", "is this skill useful", "A/B test" |
| `dispatching-parallel-agents` | 2+ independent tasks without shared state |
| `verification-before-completion` | before claiming done/fixed/passing — evidence first |

## Key Discoveries (from 4 months of usage)

Documented in [_SYNTHESIS.md §11](kiro/spec-docs/_SYNTHESIS.md):

1. **`file://~` tilde doesn't expand** in resource URIs — use absolute paths
2. **`skill://~` tilde works** — inconsistent with file://
3. **Workspace root = CWD**, not git root
4. **AGENTS.md "always included" only for default agent** — custom agents need explicit resource
5. **Shorter steering rules get better compliance** — 5-line graphify.md outperforms 67-line documentation.md
6. **Memory doesn't self-populate** — needs write instructions in AGENTS.md (the most-loaded file)
7. **Fleet orchestration** (KiroCrew) and **knowledge graphs** (graphify) are the main evolution since the original synthesis

## Running Tests

```bash
cd kiro
for t in tests/test-*.sh; do bash "$t"; done
# Expected: 170 passed, 0 failed
```

## Key Files

| File | Purpose |
|------|---------|
| `~/.kiro/steering/AGENTS.md` | Global constraints, canary, collaboration model, memory instructions |
| `~/.kiro/steering/base-constraints.md` | Scope discipline, evidence-based work, failure recovery |
| `~/.kiro/steering/security.md` | Credential protection, prompt defense baseline |
| `~/.kiro/agents/harness-default.json` | Hub agent with hooks, resources, toolsSettings |
| `~/.kiro/memory/INDEX.md` | Cross-session decision index |
| `spec-docs/_SYNTHESIS.md` | Full blueprint with §11 real-world learnings |

## License

MIT — see [LICENSE](LICENSE).
