#!/bin/bash
# Test: repo structure inventory — kiro-global contents
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
GLOBAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global" && pwd)"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

assert "[ -d \"$GLOBAL/skills\" ]" "global/skills directory exists"
assert "[ \$(ls \"$GLOBAL/skills/\" | wc -l) -ge 8 ]" "at least 8 harness skills present"
assert "[ -d \"$GLOBAL/agents\" ]" "global/agents directory exists"
assert "[ \$(ls \"$GLOBAL/agents/\"*.json | wc -l) -ge 5 ]" "5 harness agent configs present"
assert "[ -f \"$GLOBAL/steering/AGENTS.md\" ]" "global AGENTS.md exists"
assert "[ -f \"$GLOBAL/steering/base-constraints.md\" ]" "base-constraints exists"
assert "[ -f \"$GLOBAL/steering/security.md\" ]" "security exists"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
