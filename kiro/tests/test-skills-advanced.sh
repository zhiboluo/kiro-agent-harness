#!/bin/bash
# Test: advanced skills structure and content
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
SKILLS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/skills" && pwd)"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

# --- dispatching-parallel-agents enhancement ---
F="$SKILLS/dispatching-parallel-agents/SKILL.md"
assert "[ -f \"$F\" ]" "dispatching-parallel-agents: exists"
assert "[ \$(wc -l < \"$F\") -lt 500 ]" "dispatching-parallel-agents: under 500 lines"
assert "grep -q 'Structured Task Spec' \"$F\"" "dispatching-parallel-agents: has task spec section"
assert "grep -q 'Definition of Done' \"$F\"" "dispatching-parallel-agents: has DoD in template"
assert "grep -q 'Synthesis Step' \"$F\"" "dispatching-parallel-agents: has synthesis step"

# --- adversarial-review ---
F="$SKILLS/adversarial-review/SKILL.md"
assert "[ -f \"$F\" ]" "adversarial-review: exists"
assert "[ \$(wc -l < \"$F\") -lt 500 ]" "adversarial-review: under 500 lines"
assert "head -3 \"$F\" | grep -q '^---'" "adversarial-review: has YAML frontmatter"
assert "grep -q 'Skeptic' \"$F\"" "adversarial-review: has skeptic critic"
assert "grep -q 'Security Auditor' \"$F\"" "adversarial-review: has security critic"
assert "grep -q 'Scope Guardian' \"$F\"" "adversarial-review: has scope critic"
assert "grep -q 'PROCEED.*REVISE.*RETHINK' \"$F\"" "adversarial-review: has verdict options"
assert "grep -q '## Definition of Done' \"$F\"" "adversarial-review: has DoD"
assert "grep -q '## Error Handling' \"$F\"" "adversarial-review: has error handling"
assert "grep -q '## Anti-Patterns' \"$F\"" "adversarial-review: has anti-patterns"

# --- session-memory deduplication ---
F="$SKILLS/session-memory/SKILL.md"
assert "grep -q 'grep.*INDEX' \"$F\"" "session-memory: has dedup check against INDEX"
assert "grep -q 'update.*instead of creating new' \"$F\"" "session-memory: updates on duplicate"

# --- harness-evolution ---
F="$SKILLS/harness-evolution/SKILL.md"
assert "[ -f \"$F\" ]" "harness-evolution: exists"
assert "[ \$(wc -l < \"$F\") -lt 500 ]" "harness-evolution: under 500 lines"
assert "head -3 \"$F\" | grep -q '^---'" "harness-evolution: has YAML frontmatter"
assert "grep -q 'Skill gaps' \"$F\"" "harness-evolution: categorizes skill gaps"
assert "grep -q 'Skill misfires' \"$F\"" "harness-evolution: categorizes misfires"
assert "grep -q '3.*data points\|3+.*occurrences' \"$F\"" "harness-evolution: requires 3+ evidence"
assert "grep -q '## Definition of Done' \"$F\"" "harness-evolution: has DoD"
assert "grep -q '## Error Handling' \"$F\"" "harness-evolution: has error handling"
assert "grep -q '## Anti-Patterns' \"$F\"" "harness-evolution: has anti-patterns"
assert "grep -q 'A/B via subagents' \"$F\"" "harness-evolution: has A/B subagent validation"

# --- skill-effectiveness-eval ---
F="$SKILLS/skill-effectiveness-eval/SKILL.md"
assert "[ -f \"$F\" ]" "skill-effectiveness-eval: exists"
assert "[ \$(wc -l < \"$F\") -lt 500 ]" "skill-effectiveness-eval: under 500 lines"
assert "head -3 \"$F\" | grep -q '^---'" "skill-effectiveness-eval: has YAML frontmatter"
assert "grep -q 'WITHOUT skill' \"$F\"" "skill-effectiveness-eval: has baseline run"
assert "grep -q 'WITH skill' \"$F\"" "skill-effectiveness-eval: has skill run"
assert "grep -q 'KEEP.*CUT.*REVISE' \"$F\"" "skill-effectiveness-eval: has verdict thresholds"
assert "grep -q '## Definition of Done' \"$F\"" "skill-effectiveness-eval: has DoD"
assert "grep -q '## Error Handling' \"$F\"" "skill-effectiveness-eval: has error handling"
assert "grep -q '## Anti-Patterns' \"$F\"" "skill-effectiveness-eval: has anti-patterns"

# --- verification-before-completion ---
F="$SKILLS/verification-before-completion/SKILL.md"
assert "[ -f \"$F\" ]" "verification-before-completion: exists"
assert "grep -q '## Definition of Done' \"$F\"" "verification-before-completion: has DoD"
assert "grep -q '## Error Handling' \"$F\"" "verification-before-completion: has error handling"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
