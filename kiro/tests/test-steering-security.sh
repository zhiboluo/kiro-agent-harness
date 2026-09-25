#!/bin/bash
# Test: security steering content
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
F="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/steering" && pwd)/security.md"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

assert "[ -f \"$F\" ]" "file exists"
assert "[ \$(wc -l < \"$F\") -lt 100 ]" "under 100 lines"
assert "grep -q 'Credential Protection' \"$F\"" "has credential section"
assert "grep -q 'Never force push' \"$F\"" "has git security"
assert "grep -q 'GPG-signed' \"$F\"" "has GPG rule"
assert "grep -q '~/documents/' \"$F\"" "has filesystem boundary"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
