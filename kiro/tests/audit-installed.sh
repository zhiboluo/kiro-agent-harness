#!/bin/bash
# Audit: installed machine state (requires install.sh to have been run)
# This is NOT part of the default test suite — it validates the deployed machine.
# Run separately: bash tests/audit-installed.sh
set -uo pipefail
PASS=0; FAIL=0

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

echo "=== Audit: Installed Machine State ==="
echo "This tests ~/.kiro/ — requires install.sh to have been run."
echo ""

# Steering
for f in AGENTS.md base-constraints.md security.md documentation.md graphify.md; do
  assert "[ -f ~/.kiro/steering/$f ]" "steering/$f installed"
done

# Agents
for f in harness-default.json worker.json reviewer.json researcher.json planner.json; do
  assert "[ -f ~/.kiro/agents/$f ]" "agents/$f installed"
  assert "python3 -c \"import json; json.load(open('$HOME/.kiro/agents/$f'))\"" "agents/$f valid JSON"
done

# Skills
for s in session-memory context-budget-audit research-first project-harness-init session-handoff adversarial-review harness-evolution skill-effectiveness-eval; do
  assert "[ -f ~/.kiro/skills/$s/SKILL.md ]" "skills/$s installed"
done

# Memory
assert "[ -f ~/.kiro/memory/INDEX.md ]" "memory/INDEX.md exists"

# Settings (machine-specific)
assert "[ -f ~/.kiro/settings/cli.json ]" "settings/cli.json exists"
assert "python3 -c \"import json; d=json.load(open('$HOME/.kiro/settings/cli.json')); assert d.get('chat.enableKnowledge')==True\"" "knowledge enabled"
assert "python3 -c \"import json; d=json.load(open('$HOME/.kiro/settings/cli.json')); assert d.get('chat.enableTodoList')==True\"" "todo enabled"
assert "python3 -c \"import json; d=json.load(open('$HOME/.kiro/settings/cli.json')); assert d.get('chat.enableThinking')==True\"" "thinking enabled"
assert "python3 -c \"import json; d=json.load(open('$HOME/.kiro/settings/cli.json')); assert d.get('chat.enableCheckpoint')==True\"" "checkpoint enabled"
assert "python3 -c \"import json; d=json.load(open('$HOME/.kiro/settings/cli.json')); assert d.get('chat.enableSubagent')==True\"" "subagent enabled"

# No hardcoded paths in harness-default (should use current $HOME)
assert "python3 -c \"import json;home='$HOME';d=json.load(open(home+'/.kiro/agents/harness-default.json'));bad=[r for r in d.get('resources',[]) if r.startswith('file:///') and not r.startswith('file://'+home)];assert not bad,bad\"" "no foreign absolute paths in harness-default resources"

echo ""; echo "Results: $PASS passed, $FAIL failed"
echo "(This is a machine audit, not a repo test)"
[ $FAIL -eq 0 ] && exit 0 || exit 1
