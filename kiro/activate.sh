#!/bin/bash
# activate.sh — Generate machine-local workspace agent config from template
#
# Usage (from kiro/ directory):
#   bash activate.sh
#
# What it does:
#   - Copies harness-kiro.json.template → harness-kiro.json
#   - Substitutes REPLACE_WITH_HOME with current $HOME
#   - The generated file is .gitignored (machine-local)
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/.kiro/agents/harness-kiro.json.template"
TARGET="$SCRIPT_DIR/.kiro/agents/harness-kiro.json"

if [ ! -f "$TEMPLATE" ]; then
    echo "ERROR: Template not found: $TEMPLATE"
    exit 1
fi

if [ -f "$TARGET" ]; then
    echo "harness-kiro.json already exists. Overwrite? (y/N)"
    read -r answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
        echo "Skipped."
        exit 0
    fi
fi

# Portable sed: detect GNU vs BSD
if sed --version 2>/dev/null | grep -q GNU; then
    sed "s|REPLACE_WITH_HOME|$HOME|g" "$TEMPLATE" > "$TARGET"
else
    sed "s|REPLACE_WITH_HOME|$HOME|g" "$TEMPLATE" > "$TARGET"
fi

echo "✓ Generated $TARGET"
echo "  HOME=$HOME substituted"
echo ""
echo "Test: kiro-cli chat --agent harness-kiro"
