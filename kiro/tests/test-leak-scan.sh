#!/bin/bash
# Test: leak scan — greps tracked files for private tokens supplied via $LEAK_TOKENS
# Skips (counts 1 pass) when LEAK_TOKENS is unset, so contributors and forks stay green.
# CI usage: set a LEAK_TOKENS secret (newline-separated list); GitHub masks it in logs.
set -uo pipefail
PASS=0; FAIL=0

if [ -z "${LEAK_TOKENS:-}" ]; then
    echo "✓ leak scan skipped (LEAK_TOKENS not set)"
    echo ""; echo "Results: 1 passed, 0 failed"
    exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

N=0
while IFS= read -r token; do
    [ -z "$token" ] && continue
    ((N++))
    if git grep -qi -- "$token" 2>/dev/null; then
        echo "✗ LEAK: token #$N found in tracked files"
        ((FAIL++))
    else
        echo "✓ token #$N not present in tracked files"
        ((PASS++))
    fi
done <<< "$LEAK_TOKENS"

echo ""; echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
