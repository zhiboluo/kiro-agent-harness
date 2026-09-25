#!/bin/bash
# Test: base-constraints steering content
# Target: kiro/global/ (repo source of truth)
set -uo pipefail
PASS=0; FAIL=0
F="$(cd "$(dirname "${BASH_SOURCE[0]}")/../global/steering" && pwd)/base-constraints.md"

assert() {
  if eval "$1" 2>/dev/null; then ((PASS++)); echo "✓ $2"
  else ((FAIL++)); echo "✗ $2"; fi
}

assert "[ -f \"$F\" ]" "file exists"
assert "[ \$(wc -l < \"$F\") -lt 100 ]" "under 100 lines"
assert "grep -q 'verification evidence' \"$F\"" "contains evidence rule"
assert "grep -q 'YAGNI' \"$F\"" "contains YAGNI rule"
assert "grep -q 'root cause' \"$F\"" "contains failure recovery"
assert "grep -q '# Base' \"$F\"" "has heading"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
