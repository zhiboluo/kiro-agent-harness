---
name: project-harness-init
description: |
  Scaffold .kiro/ directory for a new project with steering, memory, and plans.
  Triggers: 'init project', 'setup kiro', 'scaffold project', 'new project harness',
  'project init', 'setup .kiro'. Do NOT use for: existing projects with .kiro/ already configured.
---

# Project Harness Init

Scaffold a `.kiro/` directory for a new project, establishing conventions for steering, memory, and plans.

## Purpose

New projects need consistent structure for agent context. This skill creates the minimal `.kiro/` scaffold that enables memory persistence, project-specific steering, and plan tracking.

## When to Use

- Starting a new project that will use Kiro agents
- Onboarding an existing project to the harness system
- User says "init project", "setup kiro", or "scaffold .kiro"

## Workflow

### Step 1: Detect project context
```bash
# Identify project type
ls package.json go.mod Cargo.toml pyproject.toml Makefile 2>/dev/null
# Get project name
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```
→ verify: Know the project name and primary language/framework.

### Step 2: Check for existing .kiro/
```bash
ls .kiro/ 2>/dev/null
```
→ If exists: Ask user before overwriting. Never destroy existing config.

### Step 3: Run the scaffold script
If the harness-engineering repo is available, use the setup-project.sh script:
```bash
bash <path-to-harness-engineering>/kiro/templates/setup-project.sh <project-path> <agent-name>
```
This creates: `.kiro/agents/`, `.kiro/steering/product.md`, `.kiro/memory/INDEX.md`, `.kiro/plans/`, `AGENTS.md` with canary.

If the script is not available, create the structure manually:
```bash
mkdir -p .kiro/{steering,memory/{decisions,patterns,sessions},plans,agents/prompts}
```
Then create each file per the templates in the harness-engineering repo.

### Step 4: Fill in product.md
Ask user to fill in or confirm auto-detected values for:
- What the project does
- Tech stack
- Key conventions

### Step 5: Report scaffold
```
Scaffolded .kiro/ for [project-name]:
  .kiro/steering/product.md — [needs user input / auto-filled]
  .kiro/memory/INDEX.md — empty, ready for decisions
  .kiro/plans/ — ready for plans
  AGENTS.md — with canary for drift detection
```

## Anti-Patterns

- Don't overwrite existing .kiro/ without asking.
- Don't create empty directories that serve no purpose.
- Don't add project-specific agents at init time (add when needed).
- Don't guess tech stack — detect from files or ask.

## Self-Check

- [ ] Does .kiro/ structure match the convention from _SYNTHESIS.md Section 3.1?
- [ ] Is product.md populated (not just placeholders)?
- [ ] Is .gitignore updated to exclude ephemeral files?
- [ ] Did I report what was created?

## Definition of Done

- `.kiro/` directory created with steering/, memory/, plans/ subdirectories.
- `steering/product.md` has real content (not placeholders).
- `memory/INDEX.md` exists as empty index.
- `.gitignore` excludes `.kiro/memory/sessions/`.

## Error Handling

- If .kiro/ already exists: show current state, ask what to add/update.
- If not in a git repo: skip .gitignore step, warn user.
- If project type unrecognized: ask user for tech stack info.
