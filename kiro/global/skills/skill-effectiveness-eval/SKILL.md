---
name: skill-effectiveness-eval
description: |
  Measure skill value via baseline comparison: run a task with and without a skill, compare outcomes.
  Triggers: 'evaluate skill', 'skill effectiveness', 'is this skill useful', 'measure skill value',
  'A/B test skill', 'skill benchmark'. Do NOT use for: debugging a skill, writing a new skill.
---

# Skill Effectiveness Eval

Run a task with and without a specific skill loaded, compare outcomes to determine measurable skill value.

## Purpose

Skills should earn their context budget. This skill provides a framework for quantitative evaluation: does skill X actually improve outcomes, or is it dead weight consuming tokens?

## When to Use

- Before adding a new skill to the default set (justify the context cost)
- During harness-evolution when deciding whether to keep or cut a skill
- When context budget is tight and you need to prioritize which skills stay loaded
- Monthly maintenance: spot-check skill value

## Workflow

### Step 1: Select skill and task
Choose a skill to evaluate and a representative task it should help with.
→ verify: The task is something you can run twice with measurable outcomes.

### Step 2: Define scoring criteria
Establish what "better" means for this task:
```markdown
## Eval: [skill-name] on [task-description]

Scoring criteria (rate 1-5 each):
- Correctness: Does the output meet requirements?
- Completeness: Are all aspects addressed?
- Efficiency: How many attempts/iterations needed?
- Scope discipline: Were only requested changes made?
```
→ verify: Criteria are observable, not subjective.

### Step 3: Run WITHOUT skill (baseline)
Dispatch a subagent with the task but WITHOUT the skill loaded:
```
Subagent prompt:
- Task: [exact task description]
- Context: [relevant files/code]
- Do NOT load any skill instructions for [skill-name].
- Report: what you did, what you struggled with, final result.
```
Record the outcome and score it against criteria.

### Step 4: Run WITH skill
Dispatch a subagent with the same task WITH the skill instructions prepended:
```
Subagent prompt:
- Task: [exact task description]
- Context: [relevant files/code]
- Follow these skill instructions: [full SKILL.md body]
- Report: what you did, what you struggled with, final result.
```
Record the outcome and score it against criteria.

### Step 5: Compare and decide
```markdown
## Results

| Criterion | Without Skill | With Skill | Delta |
|-----------|--------------|------------|-------|
| Correctness | X/5 | Y/5 | +/-N |
| Completeness | X/5 | Y/5 | +/-N |
| Efficiency | X/5 | Y/5 | +/-N |
| Scope discipline | X/5 | Y/5 | +/-N |
| **Total** | **X/20** | **Y/20** | **+/-N** |

Verdict: KEEP | CUT | REVISE
Rationale: [why]
```

Decision thresholds:
- **KEEP**: +3 or more improvement → skill earns its context cost
- **REVISE**: +1 to +2 → skill helps marginally, could be trimmed
- **CUT**: 0 or negative → skill adds no value, remove it

## Anti-Patterns

- Don't evaluate with a trivial task (too easy = no signal).
- Don't evaluate with a task the skill wasn't designed for.
- Don't run only one trial — results vary. Run 2-3 if time allows.
- Don't let the "with skill" subagent see the baseline results.
- Don't score subjectively — use the predefined criteria.

## Self-Check

- [ ] Was the same task used for both runs?
- [ ] Were subagents independent (fresh context each)?
- [ ] Are scores based on observable criteria, not feelings?
- [ ] Is the verdict justified by the delta?

## Definition of Done

- Baseline (without skill) scored against criteria.
- Skill run scored against same criteria.
- Comparison table produced with deltas.
- Verdict (KEEP/CUT/REVISE) recorded with rationale.

## Error Handling

- If subagent fails on baseline: task is too hard or ambiguous — simplify task, not the eval.
- If both runs score identically: skill may not apply to this task — try a different task.
- If results are inconsistent across trials: skill's value is context-dependent — note conditions.
