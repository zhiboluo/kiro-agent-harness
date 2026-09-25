---
name: session-memory
description: |
  Persist decisions, patterns, and conventions to .kiro/memory/ for cross-session continuity.
  Triggers: 'remember this', 'save decision', 'write memory',
  'what did we decide', 'store this pattern'. Do NOT use for: temporary notes, debugging logs,
  session endings (use session-handoff for 'wrap up'/'session end').
---

# Session Memory

Persist important decisions and patterns to `.kiro/memory/` so future sessions can resume without re-discovery.

## Purpose

Context windows are finite. Decisions made in one session are lost when context resets. This skill writes durable notes to disk at defined trigger points, and reads them back when a new session starts.

## When to Use

- An architectural decision was made (library choice, pattern selection, convention)
- A reusable solution was discovered (command sequence, workaround, integration pattern)
- A project convention was established or clarified
- The user says "remember this", "wrap up", or "save decision"
- Session is ending (pair with session-handoff skill)

## Memory Directory Structure

```
{project}/.kiro/memory/          # Project-specific memory (default for project work)
├── INDEX.md
├── decisions/
├── patterns/
└── sessions/

~/.kiro/memory/                  # Global memory (cross-project decisions)
├── INDEX.md
├── decisions/
└── patterns/
```

**Which path to use:**
- **Project memory** (`.kiro/memory/`): decisions specific to this project (tech stack, conventions, patterns)
- **Global memory** (`~/.kiro/memory/`): cross-project decisions (tool preferences, workflow patterns, Kiro CLI behaviors)

If unsure, use project memory. Use global only for decisions that apply across all projects.

## Workflow

### Writing Memory

#### Step 1: Identify memory-worthy event
A decision, pattern, or convention that would be useful in a future session.
→ verify: Can you articulate WHY this is worth persisting? If not, don't write it.

#### Step 2: Check for duplicates
```bash
# Search INDEX.md for existing entries on the same topic
grep -ri "keyword_from_proposed_content" .kiro/memory/INDEX.md 2>/dev/null
```
→ If similar entry exists: update it instead of creating new.
→ If topic already covered: skip write entirely (avoid duplicate).

#### Step 3: Create topic file
Write to appropriate subdirectory with date-prefixed filename:
```markdown
---
id: mem-YYYY-MM-DD-topic
type: decision | pattern | convention
importance: 1-5
created: YYYY-MM-DD
---

## Topic Title

[Concise content — max 50 lines]
```

#### Step 4: Update INDEX.md
Add one-line pointer:
```
- [mem-YYYY-MM-DD-topic] Brief description → decisions/YYYY-MM-DD-topic.md
```
→ verify: INDEX.md still under 200 lines. If over, prune oldest session entries first.

### Reading Memory

#### On session start (or when context seems missing):
1. Read `.kiro/memory/INDEX.md` if it exists
2. Load topic files relevant to current task (by keyword match)
3. Total loaded memory should stay under 5K tokens

## Anti-Patterns

- Don't write debugging logs or temporary state to memory.
- Don't write things already in project docs or README.
- Don't write full code — write the decision/pattern description only.
- Don't exceed 50 lines per memory file.
- Don't let INDEX.md grow past 200 lines.

## Sediment Protocol (End-of-Task)

At task completion, evaluate what to persist. Sediment categories:
- **Confirmed preferences**: user's answer style, default goals per project, hated patterns
- **Reusable commands/paths/flows**: commands that worked, file paths frequently referenced
- **Pitfalls to avoid**: approaches that failed and why
- **Follow-up items**: deferred work the user acknowledged

### Anti-Drift Rules
- Only store stable preferences (confirmed across 2+ interactions, not one-off).
- Distinguish facts from inference — tag entries as "verified" or "inferred".
- Re-verify stale entries: if an entry is >30 days old and referenced, confirm it still holds.
- Never store transient debugging state or intermediate exploration results.

## Self-Check

Before writing memory:
- [ ] Is this stable (won't change next week)?
- [ ] Would a future session benefit from knowing this?
- [ ] Is it concise (under 50 lines)?
- [ ] Does a similar entry already exist in INDEX.md?

## Definition of Done

- Memory file created in correct subdirectory with valid frontmatter.
- INDEX.md updated with pointer to new file.
- INDEX.md remains under 200 lines.
- No duplicate entries for same topic.

## Error Handling

- If `.kiro/memory/` doesn't exist: create it with INDEX.md + subdirectories.
- If INDEX.md exceeds 200 lines after write: prune oldest session entries (7-day TTL).
- If duplicate detected: update existing file, don't create new one.
