# Harness Engineering for Kiro CLI

## Canary
Every response MUST begin with: [REPLACE_WITH_YOUR_CANARY]

> Project-specific instructions. Global constraints are in ~/.kiro/steering/AGENTS.md.

## Project Context
This repository implements a harness engineering system for Kiro CLI. The blueprint is in `spec-docs/_SYNTHESIS.md`.

## Project Structure
- `spec-docs/` — Blueprint and reference documents
- `.kiro/agents/` — Agent configs (JSON)
- `.kiro/plans/` — Implementation progress tracking
- `tests/` — E2E test scripts for each task

## Conventions
- Follow the phased roadmap in _SYNTHESIS.md (Phase 1 → 2 → 3)
- Every task needs a passing test before advancing
- Use `kiro/` subdirectory for Kiro harness; `claude/` is reserved for Claude Code (later)
