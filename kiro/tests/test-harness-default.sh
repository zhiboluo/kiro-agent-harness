#!/bin/bash
# Test: harness-default agent config
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
F="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/agents" && pwd)/harness-default.json"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

assert "[ -f \"$F\" ]" "file exists"
assert "python3 -c \"import json; json.load(open('$F'))\"" "valid JSON"
assert "python3 -c \"import json; d=json.load(open('$F')); assert d['name']=='harness-default'\"" "name is harness-default"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'toolsSettings' in d\"" "has toolsSettings"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'hooks' in d\"" "has hooks"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'resources' in d\"" "has resources"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'deniedCommands' in d['toolsSettings']['shell']\"" "has deniedCommands"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'agentSpawn' in d['hooks']\"" "has agentSpawn hook"
assert "python3 -c \"import json; d=json.load(open('$F')); h=d['hooks']['preToolUse'][0]; assert h['matcher']=='*' and 'block-credentials' in h['command']\"" "has preToolUse credential-block hook"
assert "python3 -c \"import json; d=json.load(open('$F')); assert d['model'].startswith('claude-opus')\"" "model is opus"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'git checkout -- .*' in d['toolsSettings']['shell']['deniedCommands']\"" "denies git checkout -- (work discard)"
assert "python3 -c \"import json; d=json.load(open('$F')); assert 'git restore .*' in d['toolsSettings']['shell']['deniedCommands']\"" "denies git restore (work discard)"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
