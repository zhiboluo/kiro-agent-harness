---
name: research-first
description: |
  Search existing solutions before implementing anything new.
  Triggers: 'how does this work', 'is there already', 'existing solution', 'research first',
  'before implementing', 'check if exists'. Do NOT use for: tasks with clear specs already.
---

# Research First

Search for existing solutions in the codebase, docs, and patterns before implementing anything new.

## Purpose

Reinventing existing solutions wastes time and creates inconsistency. This skill ensures you look before you build — checking the codebase, project docs, and memory for existing patterns that solve the problem.

## When to Use

- Starting a new feature that might already exist partially
- Implementing a pattern that the codebase might already have
- Unfamiliar with how something works in this project
- Before introducing a new library or dependency

## Workflow

### Step 1: Define what you're looking for
State clearly: "I need to find how [X] is done in this project."
→ verify: The question is specific enough to search for.

### Step 2: Search the codebase

**Start with the knowledge graph (if available):**
```bash
# Check if graphify graph exists for this project
ls graphify-out/graph.json 2>/dev/null
```
If `graphify-out/graph.json` exists, query it first — it returns focused subgraphs faster than grep:
```bash
graphify query "<what you're looking for>"
graphify path "ConceptA" "ConceptB"  # trace connections between concepts
```

**Then supplement with text search:**
```bash
# Search for existing implementations
grep -r "keyword" src/ --include="*.ts" --include="*.go" --include="*.py" -l
# Search for patterns
find . -name "*relevant*" -not -path "*/node_modules/*"
# Use code intelligence
# code tool: search_symbols for functions/classes
```
→ verify: You checked at least 2 search strategies (graphify counts as one).

### Step 3: Check project documentation
- Read README, CONTRIBUTING, architecture docs
- Check `.kiro/memory/` for past decisions on this topic
- Look for relevant comments in existing code

### Step 4: Evaluate findings
- **Found existing solution**: Use it. Adapt if needed, don't rewrite.
- **Found partial solution**: Extend it. Follow its patterns.
- **Found nothing**: Proceed with new implementation, but document why.
- **Found conflicting approaches**: Note both, ask user which to follow.

### Step 5: Report findings before acting
```
## Research Summary
- Searched: [what you searched]
- Found: [what exists]
- Decision: [use existing / extend / build new]
- Rationale: [why]
```
→ verify: User acknowledged findings before implementation begins.

## Anti-Patterns

- Don't skip research because "it's faster to just build it."
- Don't search superficially (one grep) and declare "nothing found."
- Don't ignore existing solutions because yours would be "better."
- Don't research endlessly — cap at 5 minutes, then decide.

## Self-Check

- [ ] Did I search code, docs, AND memory?
- [ ] Did I try at least 2 different search terms?
- [ ] Did I report findings before implementing?
- [ ] If building new: did I explain why existing solutions don't fit?

## Definition of Done

- Research summary documented (searched, found, decision, rationale).
- User acknowledged before implementation proceeds.
- If existing solution found: it's being used or extended, not reimplemented.

## Error Handling

- If search tools are unavailable: use shell grep/find as fallback.
- If codebase is too large for broad search: narrow scope to most likely directories.
- If user says "just build it": note that research was skipped, proceed.
