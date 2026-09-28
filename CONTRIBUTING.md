# Contributing

## Setup

```bash
git clone https://github.com/zhiboluo/kiro-agent-harness.git
cd kiro-agent-harness/kiro
for t in tests/test-*.sh; do bash "$t"; done   # all must pass
```

## Ground rules

- **Tests must pass before every commit.** CI runs the suite on Ubuntu and macOS, including a checkout path containing spaces. Don't assume GNU userland — `sed -i`, `sha256sum`, and friends behave differently on macOS/BSD.
- **Skill format** — new or changed skills follow `_SYNTHESIS.md` §3.2: frontmatter (`name`, `description` ending with `Triggers:` / `Do NOT use for:`), then Purpose / When to Use / Workflow with `→ verify:` lines / Anti-Patterns / Self-Check / Definition of Done / Error Handling.
- **Markdown frontmatter** — agent-created markdown follows the tiers in `kiro/global/steering/documentation.md` (steering files: `scope`/`updated`/`version`; spec docs: `type`/`generated`/`author`/`created`/`version`).
- **Commits** — short imperative subject prefixed `fix:` / `feat:` / `docs:` / `ci:` / `test:`, one concern per commit.
- **No private data** — no internal hostnames, usernames, personal canaries, or scraped third-party documentation. CI supports an optional leak scan via a `LEAK_TOKENS` secret.
- **Scope discipline** — the repo's own steering applies to contributions too: every changed line should trace to the change's purpose. No drive-by refactors.

## What's welcome

- Portability fixes (GNU/BSD, spaces in paths)
- New skills that follow the format and add test assertions
- Test strengthening — structural checks (JSON parsing, behavior) over string greps
