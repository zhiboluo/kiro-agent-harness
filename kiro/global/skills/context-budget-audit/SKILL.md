---
name: context-budget-audit
description: |
  Audit loaded context components, estimate token usage, and recommend optimizations.
  Triggers: 'context budget', 'token usage', 'what is loaded', 'context audit',
  'too much context', 'context heavy', 'optimize context'. Do NOT use for: general debugging.
---

# Context Budget Audit

Inventory all loaded context components, estimate their token cost, and recommend what to unload or compress.

## Purpose

Context windows have limits. When too much is loaded, quality degrades (lost-in-the-middle effect). This skill audits what's consuming context and recommends optimizations.

## When to Use

- Context feels slow or responses miss obvious information
- Before starting a complex task that needs maximum free context
- After loading multiple skills or large files
- When context compaction triggers frequently

## Workflow

### Step 1: Inventory loaded components
List all currently active context sources:
```
- Steering files (always loaded): count and estimate size
- Active skills (triggered): list names
- Memory files loaded: list
- Conversation history: estimate length
- Files read in session: list
```
→ verify: Every item has an estimated token count.

### Step 2: Estimate token usage
Use approximation: 1 token ≈ 4 characters (English), 1 token ≈ 2 characters (code).

| Component | Budget Target | Action if Over |
|-----------|--------------|----------------|
| Steering files (all) | < 2K tokens | Split or trim verbose files |
| Skill index (descriptions) | < 1.5K tokens | Shorten descriptions |
| Loaded skill bodies | < 25K tokens total | Unload unused skills |
| Memory | < 5K tokens | Prune old entries |
| Single skill body | < 5K tokens | Move detail to references/ |

### Step 3: Classify by necessity
For each loaded component, classify:
- **Always needed**: steering files, active task context
- **Sometimes needed**: skills triggered for current task
- **Rarely needed**: skills loaded but not actively used, old memory

### Step 4: Recommend actions
Output a prioritized savings report:
```
## Context Budget Report

Total estimated: ~XX,000 tokens
Budget remaining: ~YY,000 tokens (of ~200K window)

### Recommendations (highest savings first):
1. [Component] — ~N tokens — [action: unload/compress/move to references]
2. ...
```

## Anti-Patterns

- Don't obsess over exact token counts — estimates within 20% are fine.
- Don't unload steering files (they're always needed).
- Don't recommend removing context the user explicitly loaded.
- Don't run this audit every session — only when there's a signal of pressure.

## Self-Check

- [ ] Did I list ALL loaded components (not just skills)?
- [ ] Are estimates reasonable (not wildly over/under)?
- [ ] Are recommendations actionable (specific file, specific action)?
- [ ] Did I preserve always-needed components?

## Definition of Done

- Complete inventory of loaded components with token estimates.
- Classification into always/sometimes/rarely needed.
- Prioritized recommendations with estimated savings.

## Error Handling

- If unable to determine what's loaded: state limitations, recommend `/context show`.
- If context is healthy (under 50% usage): report "no action needed" with current stats.
