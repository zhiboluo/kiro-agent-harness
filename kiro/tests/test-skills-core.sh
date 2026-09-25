#!/bin/bash
# Test: core skills structure and content
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
SKILLS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/skills" && pwd)"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

for skill in session-memory context-budget-audit research-first project-harness-init session-handoff; do
  F="$SKILLS/$skill/SKILL.md"
  assert "[ -f \"$F\" ]" "$skill: file exists"
  assert "[ \$(wc -l < \"$F\") -lt 500 ]" "$skill: under 500 lines"
  assert "head -3 \"$F\" | grep -q '^---'" "$skill: has YAML frontmatter"
  assert "grep -q '^name:' \"$F\"" "$skill: has name field"
  assert "grep -q '^description:' \"$F\" || grep -q '^  description:' \"$F\"" "$skill: has description field"
  assert "grep -q '## Definition of Done' \"$F\"" "$skill: has Definition of Done"
  assert "grep -q '## Error Handling' \"$F\"" "$skill: has Error Handling"
  assert "grep -q '## Anti-Patterns' \"$F\"" "$skill: has Anti-Patterns"
  assert "grep -q '## Self-Check' \"$F\"" "$skill: has Self-Check"
  assert "grep -q '## Workflow' \"$F\" || grep -q '## When to Use' \"$F\"" "$skill: has workflow or usage section"
done

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
