---
name: session-handoff
description: |
  Create a clean session end with progress updates, decision persistence, and handoff notes.
  Triggers: 'end session', 'wrap up', 'handoff', 'session end', 'stopping for today',
  'continue later', 'save progress'. Do NOT use for: mid-session saves, quick notes.
---

# Session Handoff

Create a structured session-end artifact that enables the next session to resume without re-exploration.

## Purpose

Sessions end. Context resets. Without a handoff note, the next session wastes time rediscovering what was done, what's pending, and what decisions were made. This skill captures that state at session end.

## When to Use

- User signals session end ("wrap up", "stopping for today", "continue later")
- Context window approaching limit (preemptive handoff before compaction)
- Switching to a different task/project

## Workflow

### Step 1: Summarize progress
```markdown
## What Was Done
- [Completed items with evidence]

## What's In Progress
- [Partially done items with current state]

## What's Blocked
- [Items that need input/resolution]
```
→ verify: Each item has enough context for a fresh session to understand.

### Step 2: Capture decisions made this session
For each decision worth persisting, invoke the session-memory skill to write it.
→ verify: Only stable decisions (not experiments or temporary choices).

### Step 3: Update plan progress (if plan active)
```bash
# If .kiro/plans/current-plan.md exists, update task statuses
```
→ verify: Plan reflects actual completed/pending state.

### Step 4: Write handoff note
Save to `.kiro/memory/sessions/YYYY-MM-DD-handoff.md`:
```markdown
---
id: session-YYYY-MM-DD
type: handoff
created: YYYY-MM-DD
ttl: 7d
---

## Session Summary

### Completed
- [items]

### Next Steps
- [what to do next, in priority order]

### Key Context
- [anything the next session needs to know immediately]
- [current branch, relevant files, test state]

### Open Questions
- [unresolved items needing user input]
```

### Step 5: Update INDEX.md
Add pointer to the handoff note in `.kiro/memory/INDEX.md`.
→ verify: INDEX.md under 200 lines. Prune old session entries if needed.

## Anti-Patterns

- Don't write vague summaries ("worked on stuff").
- Don't include full code in handoff notes — reference file paths.
- Don't skip the "Next Steps" section — it's the most valuable part.
- Don't persist temporary debugging state as decisions.

## Self-Check

- [ ] Could a fresh session resume from this note alone?
- [ ] Are next steps specific and actionable?
- [ ] Were new decisions persisted via session-memory?
- [ ] Is the plan updated if one was active?

## Definition of Done

- Handoff note written to `.kiro/memory/sessions/`.
- INDEX.md updated with pointer.
- Active plan updated (if applicable).
- New decisions persisted to memory/decisions/.

## Error Handling

- If `.kiro/memory/` doesn't exist: create it (invoke project-harness-init).
- If no plan active: skip plan update step.
- If session was just exploration (no concrete progress): write minimal note with findings only.
