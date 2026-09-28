#!/bin/bash
# Test: subagent JSON configs — tools, models, privileges
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
AGENTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/agents" && pwd)"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

for agent in worker reviewer researcher planner; do
  assert "[ -f \"$AGENTS/$agent.json\" ]" "$agent.json exists"
  assert "python3 -c \"import json; d=json.load(open('$AGENTS/$agent.json')); assert all(k in d for k in ['name','description','prompt','tools'])\"" "$agent.json has required fields"
  assert "python3 -c \"import json; d=json.load(open('$AGENTS/$agent.json')); assert 'preToolUse' in d['hooks']\"" "$agent.json has preToolUse hook"
done

# Role-specific checks
assert "python3 -c \"import json; d=json.load(open('$AGENTS/worker.json')); assert 'write' in d['tools']\"" "worker has write tool"
assert "python3 -c \"import json; d=json.load(open('$AGENTS/reviewer.json')); assert 'write' not in d['tools']\"" "reviewer has no write tool"
assert "python3 -c \"import json; d=json.load(open('$AGENTS/researcher.json')); assert 'write' not in d['tools']\"" "researcher has no write tool"
assert "python3 -c \"import json; d=json.load(open('$AGENTS/planner.json')); assert 'write' not in d['tools']\"" "planner has no write tool"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
