---
name: harness-evolution
description: |
  Analyze session history for failure patterns and propose skill/steering improvements.
  Triggers: 'improve harness', 'evolve skills', 'what keeps failing', 'harness evolution',
  'skill improvement', 'review failures'. Do NOT use for: fixing a specific current bug.
---

# Harness Evolution

Analyze session logs and memory to identify repeated failures, then propose concrete improvements to skills or steering files.

## Purpose

The harness should improve itself based on observed patterns. Instead of intuition-driven changes, this skill uses evidence from past sessions: what failed, what was retried, what workarounds emerged. Changes are proposed as diffs, tested via comparison, and kept only if they produce better outcomes.

## When to Use

- After completing a multi-session project (retrospective)
- When the same failure pattern appears 3+ times
- Periodically (monthly maintenance per _SYNTHESIS §9)
- When user says "improve harness" or "what keeps failing"

## Workflow

### Step 1: Gather evidence
```bash
# Read session memory for failure patterns
cat .kiro/memory/INDEX.md
ls .kiro/memory/patterns/ .kiro/memory/decisions/

# Check recent session handoffs for recurring issues
ls .kiro/memory/sessions/

# Search for repeated failure signals
grep -ri "failed\|blocked\|retry\|workaround" .kiro/memory/ 2>/dev/null
```
→ verify: Have at least 3 data points before proposing changes.

### Step 2: Identify patterns
Categorize findings into:
- **Skill gaps**: Situations where no skill triggered but should have
- **Skill misfires**: Skills that triggered but gave wrong guidance
- **Steering gaps**: Rules that were needed but absent
- **Convention drift**: Established patterns that were forgotten

### Step 3: Propose changes
For each identified pattern, propose a concrete change:
```markdown
## Proposed Change: [name]

**Evidence:** [what failed, how many times, in what context]
**Root cause:** [why the current harness didn't handle this]
**Proposed fix:** [exact diff to skill/steering file]
**Expected outcome:** [what should improve]
**Risk:** [what could go wrong with this change]
```
→ verify: Each proposal traces to specific evidence, not intuition.

### Step 4: Validate changes
For each proposed change:
1. Apply the change
2. Re-run the scenario that triggered the failure (if reproducible)
3. Check that existing tests still pass
4. **A/B via subagents**: Dispatch two subagents with the same task — one with the old skill/steering, one with the proposed change. Compare outcomes. Keep only if the new version scores better.
5. If improvement confirmed: keep. If not: revert.

### Step 5: Document evolution
Use the **session-memory** skill to persist results. For each change applied or rejected, invoke session-memory's write workflow:
- Type: `pattern` for applied changes, `decision` for rejected changes with rationale
- Subdirectory: `memory/patterns/YYYY-MM-DD-harness-evolution.md`
- Include: evidence, what changed, what improved (or why rejected)

This ensures entries appear in INDEX.md and follow the memory frontmatter convention.

## Anti-Patterns

- Don't propose changes based on a single failure (need 3+ occurrences).
- Don't make skills longer just to cover edge cases — consider steering rules instead.
- Don't remove constraints without understanding why they were added.
- Don't apply changes without testing (no "this should help" without evidence).
- Don't evolve skills for problems that are actually user-specific preferences (use memory instead).

## Self-Check

- [ ] Is every proposed change backed by 3+ evidence points?
- [ ] Did I check existing tests still pass after changes?
- [ ] Are rejected changes documented with reasoning?
- [ ] Did I avoid making skills longer without clear benefit?

## Definition of Done

- Evidence gathered from session history (failures, retries, workarounds).
- Patterns identified and categorized.
- Changes proposed with evidence, root cause, and expected outcome.
- Changes validated (applied + tested or explicitly deferred).
- Evolution documented in memory.

## Error Handling

- If no session history exists: report "insufficient data" and suggest running for 2+ weeks before retrying.
- If patterns are ambiguous: document as "open issues" rather than guessing fixes.
- If a proposed change breaks existing tests: revert immediately, document why.
