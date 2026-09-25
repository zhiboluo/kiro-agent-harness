---
name: adversarial-review
description: |
  Multi-perspective critique of plans, designs, or implementations via parallel subagents.
  Triggers: 'adversarial review', 'critique this plan', 'stress test this design',
  'find holes in this', 'red team', 'devil advocate'. Do NOT use for: simple code review
  (use requesting-code-review), single-file fixes, or trivial changes.
---

# Adversarial Review

Spawn 3 hostile critic subagents in parallel, each with a different critical lens, to attack a plan or design before implementation begins.

## Purpose

Plans fail in production because a single reviewer has blind spots. Three independent critics with distinct mandates find more issues than one generalist reviewer. Only insights that survive all three perspectives proceed to implementation.

## When to Use

- Before implementing a major design or plan (>3 tasks)
- After brainstorming produces a spec that touches multiple subsystems
- When the stakes of getting it wrong are high (auth, data model, public API)
- When you suspect confirmation bias in the current approach

## When NOT to Use

- Simple code changes (<50 lines)
- Bug fixes with clear root cause
- Tasks with externally-defined specs (no design latitude)

## Workflow

### Step 1: Prepare the artifact for review
Identify what to critique: a spec file, plan file, or architecture decision.
→ verify: The artifact is a complete, self-contained document (not scattered notes).

### Step 2: Dispatch 3 critic subagents in parallel

Each gets the SAME artifact but a DIFFERENT critical mandate:

**Critic 1 — Skeptic (Feasibility)**
```
You are a skeptical engineer. Your job is to find reasons this plan will FAIL.

Artifact to critique:
[full artifact text]

Your mandate:
- What assumptions are unvalidated?
- What dependencies could break?
- Where will the hardest integration points be?
- What's missing that will only be discovered during implementation?
- What will take 3x longer than estimated?

Output: List of concerns ranked by severity (BLOCKING / SERIOUS / MINOR).
Only report real risks, not hypotheticals. Cite specific parts of the artifact.
```

**Critic 2 — Security Auditor**
```
You are a security auditor. Your job is to find security vulnerabilities in this design.

Artifact to critique:
[full artifact text]

Your mandate:
- What attack surfaces does this create?
- Where is input not validated?
- Where could credentials leak?
- What permissions are too broad?
- Are there TOCTOU races or privilege escalation paths?

Output: List of security concerns ranked by severity (CRITICAL / HIGH / MEDIUM / LOW).
Only report concerns relevant to THIS specific design. No generic advice.
```

**Critic 3 — Scope Guardian**
```
You are a scope guardian. Your job is to find unnecessary complexity and scope creep.

Artifact to critique:
[full artifact text]

Your mandate:
- What features are not required by the stated goal?
- What could be deferred to a later iteration?
- Where is the design over-engineered for current needs?
- What abstractions add complexity without proven benefit?
- Is there a simpler approach that meets the same requirements?

Output: List of scope concerns ranked as (CUT / DEFER / SIMPLIFY).
Only flag things that genuinely don't serve the stated goal.
```

### Step 3: Collect and merge verdicts
Wait for all 3 subagents to return. Merge their findings into a single report:

```markdown
## Adversarial Review Summary

### Blocking Issues (must fix before implementation)
- [from any critic — issues that would cause failure]

### Serious Concerns (should fix, or explicitly accept risk)
- [issues that significantly increase risk]

### Minor/Deferred
- [issues noted but not blocking]

### Verdict: PROCEED | REVISE | RETHINK
```

### Step 4: Act on results

- **PROCEED**: No blocking issues. Note serious concerns for monitoring during implementation.
- **REVISE**: Blocking issues found but fixable. Update the artifact, optionally re-run review.
- **RETHINK**: Fundamental problems. Return to brainstorming/design phase.

## Anti-Patterns

- Don't run adversarial review on trivial changes (overkill).
- Don't ignore blocking issues because "we'll fix it later."
- Don't let critics see each other's output (independence matters).
- Don't ask critics to also suggest solutions (separate concern).
- Don't use this as a substitute for post-implementation code review.

## Self-Check

- [ ] Did all 3 critics return independently?
- [ ] Are blocking issues addressed before proceeding?
- [ ] Is the merged summary written to a reviewable artifact?
- [ ] Was the verdict explicitly stated (PROCEED/REVISE/RETHINK)?

## Definition of Done

- 3 critic subagents dispatched in parallel with distinct mandates.
- All 3 returned verdicts independently.
- Merged summary produced with severity-ranked findings.
- Blocking issues either resolved or explicitly accepted with rationale.
- Verdict recorded (PROCEED/REVISE/RETHINK).

## Error Handling

- If a critic subagent fails or returns empty: re-dispatch with same mandate once. If still fails, proceed with 2/3 critics and note the gap.
- If critics contradict each other: the more conservative position wins for security; the simpler position wins for scope.
- If all 3 critics find blocking issues: this is a RETHINK signal, not a "fix and continue."
