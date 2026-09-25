#!/bin/bash
# Test: install.sh and setup-project.sh behavioral tests
# Runs against temp $HOME — no machine dependency
set -uo pipefail
PASS=0; FAIL=0
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

# --- install.sh tests ---
echo "=== install.sh behavioral tests ==="
FAKE_HOME=$(mktemp -d)

HOME="$FAKE_HOME" bash "$REPO_ROOT/global/install.sh" >/dev/null 2>&1
assert "[ \$(find \"$FAKE_HOME/.kiro\" -type f | wc -l) -ge 22 ]" "install: deploys 22+ files"
assert "[ -f \"$FAKE_HOME/.kiro/steering/AGENTS.md\" ]" "install: steering deployed"
assert "[ -f \"$FAKE_HOME/.kiro/agents/harness-default.json\" ]" "install: agents deployed"
assert "[ -f \"$FAKE_HOME/.kiro/skills/session-memory/SKILL.md\" ]" "install: skills deployed"
assert "[ -f \"$FAKE_HOME/.kiro/memory/INDEX.md\" ]" "install: memory deployed"

# Verify tilde paths were converted
assert "! grep -q 'file://~/' \"$FAKE_HOME/.kiro/agents/harness-default.json\"" "install: no file://~ tilde left"
assert "grep -q \"file://$FAKE_HOME\" \"$FAKE_HOME/.kiro/agents/harness-default.json\"" "install: absolute path injected"

# Test --force mode
echo "MODIFIED" > "$FAKE_HOME/.kiro/steering/AGENTS.md"
HOME="$FAKE_HOME" bash "$REPO_ROOT/global/install.sh" >/dev/null 2>&1
assert "head -1 \"$FAKE_HOME/.kiro/steering/AGENTS.md\" | grep -q 'MODIFIED'" "install: skip mode preserves existing"

HOME="$FAKE_HOME" bash "$REPO_ROOT/global/install.sh" --force >/dev/null 2>&1
assert "head -1 \"$FAKE_HOME/.kiro/steering/AGENTS.md\" | grep -q '# Global'" "install: --force overwrites"

rm -r "$FAKE_HOME"

# --- setup-project.sh tests ---
echo ""
echo "=== setup-project.sh behavioral tests ==="
TMPDIR=$(mktemp -d)

bash "$REPO_ROOT/templates/setup-project.sh" "$TMPDIR" "test-app" >/dev/null 2>&1
assert "[ -f \"$TMPDIR/.kiro/agents/test-app.json\" ]" "scaffold: agent config created"
assert "[ -f \"$TMPDIR/.kiro/agents/prompts/test-app-prompt.md\" ]" "scaffold: prompt created"
assert "[ -f \"$TMPDIR/AGENTS.md\" ]" "scaffold: AGENTS.md created"
assert "[ -f \"$TMPDIR/.kiro/steering/product.md\" ]" "scaffold: product.md created"
assert "[ -f \"$TMPDIR/.kiro/memory/INDEX.md\" ]" "scaffold: memory INDEX created"
assert "[ -d \"$TMPDIR/.kiro/plans\" ]" "scaffold: plans/ created"

# Verify name substitution
assert "python3 -c \"import json; d=json.load(open('$TMPDIR/.kiro/agents/test-app.json')); assert d['name']=='test-app'\"" "scaffold: name substituted"
assert "grep -q 'file://AGENTS.md' \"$TMPDIR/.kiro/agents/test-app.json\"" "scaffold: AGENTS.md in resources"
assert "grep -q 'test-app' \"$TMPDIR/.kiro/agents/prompts/test-app-prompt.md\"" "scaffold: prompt references agent name"

# Verify skip on existing
bash "$REPO_ROOT/templates/setup-project.sh" "$TMPDIR" "test-app" >/dev/null 2>&1
assert "[ \$(find \"$TMPDIR\" -name 'AGENTS.md' | wc -l) -eq 1 ]" "scaffold: doesn't duplicate AGENTS.md"

rm -r "$TMPDIR"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
