---
scope: global
updated: 2026-09-02
version: "1.0"
---

# Documentation Standards

Every Markdown file created or modified by an agent must begin with a YAML frontmatter block
(between `---` markers) appropriate to its tier. Use the `doc-header` skill for copy-paste templates.

## Tier 1 — Handoff files (`handoff/*.md`)

Short-lived inter-agent communication. Required fields:

```yaml
---
from: dev                         # agent role that wrote this
to: orchestrator                  # intended recipient
status: DONE                      # DONE | FAIL | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
task: "one-line task description"
created: 2026-09-02T03:15:00Z     # ISO 8601, UTC
ticket: PROJ-1234               # omit if not ticket-driven
model: claude-sonnet-5            # optional — model that generated this
---
```

## Tier 2 — Spec / design / analysis / review docs (`spec-docs/**/*.md`)

Sprint-lived documents saved to the repository. Required fields:

```yaml
---
type: design         # design | analysis | plan | review | test-plan | synthesis
ticket: PROJ-1234
generated: true
author: agent-role   # agent role (e.g. orchestrator-scrum) or human name
created: 2026-09-02
version: "0.1"
branch: PROJ-1234-description   # optional — omit if not branch-specific
model: claude-opus-5              # optional
---
```

## Tier 3 — Steering files (`.kiro/steering/*.md`)

Durable configuration. Required fields:

```yaml
---
scope: project       # global | project
updated: 2026-09-02
version: "1.0"
created: 2026-09-02  # optional — date rule was first established
---
```

## Tier 4 — Memory files (`.kiro/memory/**/*.md`)

Persistent cross-session decisions and patterns. Required fields:

```yaml
---
id: mem-YYYY-MM-DD-topic
type: decision       # decision | pattern | convention
importance: 3        # 1 (low) to 5 (critical)
created: YYYY-MM-DD
---
```

- Memory files max 50 lines. INDEX.md max 200 lines.
- `type` is one of: `decision`, `pattern`, `convention`.

## Rules

- **Never omit the frontmatter block** on a new file. An empty block (`---\n---`) is not acceptable.
- **`created` timestamps** use ISO 8601 UTC (`T` separator, `Z` suffix). Date-only (`2026-09-02`) is acceptable for Tier 2/3.
- **`status` on handoff files** must be one of the five values above — no free-text.
- **`version`** follows semver-lite: `"0.1"` → `"0.2"` → `"1.0"`. Bump minor on content changes, major on structural changes.
- **Existing files without frontmatter**: add a Tier 3 block (`scope/updated/version`) at the top when making other edits to that file. Do not rewrite the file just to add headers.
- **`generated: true`** marks AI-produced content. Human-authored files omit this field.
- **`task-context.md`** in `handoff/` is written by orchestrator as a task plan — use Tier 2 (`type: plan`), not Tier 1.
- **Jira comments** from agents must end with `_YYYY-MM-DD HH:MM TZ  [AI generated]_` on the last line — suffix, not prefix (adjust to your tracker conventions).
