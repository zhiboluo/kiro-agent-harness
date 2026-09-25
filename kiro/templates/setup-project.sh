#!/bin/bash
# setup-project.sh — Scaffold a customized Kiro agent for a project
#
# Usage:
#   bash setup-project.sh <project-path> <agent-name>
#
# Example:
#   bash setup-project.sh ~/projects/my-app my-app
#
# Prerequisites:
#   - Global harness installed (run kiro/global/install.sh first)
#   - Project directory exists
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR"

if [ $# -lt 2 ]; then
    echo "Usage: bash setup-project.sh <project-path> <agent-name>"
    echo "Example: bash setup-project.sh ~/projects/my-app my-app"
    exit 1
fi

PROJECT_PATH="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
AGENT_NAME="$2"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project directory does not exist: $PROJECT_PATH"
    exit 1
fi

echo "Scaffolding Kiro agent '$AGENT_NAME' for $PROJECT_PATH ..."
echo ""

# Create directory structure
mkdir -p "$PROJECT_PATH/.kiro/agents/prompts"
mkdir -p "$PROJECT_PATH/.kiro/steering"
mkdir -p "$PROJECT_PATH/.kiro/memory/"{decisions,patterns,sessions}
mkdir -p "$PROJECT_PATH/.kiro/plans"

# Copy and customize agent config
sed -e "s|PROJECT_NAME|$AGENT_NAME|g" \
    -e "s|REPLACE_WITH_HOME|$HOME|g" \
    -e "s|DESCRIBE_WHAT_THIS_AGENT_DOES|Custom agent for $AGENT_NAME project|g" \
    "$TEMPLATE_DIR/.kiro/agents/PROJECT_NAME.json" \
    > "$PROJECT_PATH/.kiro/agents/$AGENT_NAME.json"
echo "  ✓ .kiro/agents/$AGENT_NAME.json"

# Copy and customize agent prompt
sed "s|PROJECT_NAME|$AGENT_NAME|g" \
    "$TEMPLATE_DIR/.kiro/agents/prompts/PROJECT_NAME-prompt.md" \
    > "$PROJECT_PATH/.kiro/agents/prompts/$AGENT_NAME-prompt.md"
echo "  ✓ .kiro/agents/prompts/$AGENT_NAME-prompt.md"

# Copy AGENTS.md (workspace root)
if [ ! -f "$PROJECT_PATH/AGENTS.md" ]; then
    sed -e "s|PROJECT_NAME|$AGENT_NAME|g" \
        -e "s|REPLACE_WITH_YOUR_CANARY|$(date +%s | { sha256sum 2>/dev/null || shasum -a 256; } | head -c 8)|g" \
        "$TEMPLATE_DIR/AGENTS.md" \
        > "$PROJECT_PATH/AGENTS.md"
    echo "  ✓ AGENTS.md (with generated canary)"
else
    echo "  SKIP AGENTS.md (already exists)"
fi

# Copy steering template
if [ ! -f "$PROJECT_PATH/.kiro/steering/product.md" ]; then
    sed "s|PROJECT_NAME|$AGENT_NAME|g" \
        "$TEMPLATE_DIR/.kiro/steering/product.md" \
        > "$PROJECT_PATH/.kiro/steering/product.md"
    echo "  ✓ .kiro/steering/product.md"
else
    echo "  SKIP .kiro/steering/product.md (already exists)"
fi

# Copy memory INDEX
if [ ! -f "$PROJECT_PATH/.kiro/memory/INDEX.md" ]; then
    cp "$TEMPLATE_DIR/.kiro/memory/INDEX.md" "$PROJECT_PATH/.kiro/memory/INDEX.md"
    echo "  ✓ .kiro/memory/INDEX.md"
else
    echo "  SKIP .kiro/memory/INDEX.md (already exists)"
fi

# Add sessions to .gitignore if in a git repo
if [ -d "$PROJECT_PATH/.git" ]; then
    if ! grep -q ".kiro/memory/sessions/" "$PROJECT_PATH/.gitignore" 2>/dev/null; then
        echo ".kiro/memory/sessions/" >> "$PROJECT_PATH/.gitignore"
        echo "  ✓ .gitignore updated (sessions/ excluded)"
    fi
fi

echo ""
echo "Done. Next steps:"
echo "  1. Edit $PROJECT_PATH/AGENTS.md — add project context and canary"
echo "  2. Edit $PROJECT_PATH/.kiro/steering/product.md — describe tech stack and conventions"
echo "  3. Edit $PROJECT_PATH/.kiro/agents/$AGENT_NAME.json — customize description"
echo "  4. Launch: cd $PROJECT_PATH && kiro-cli chat --agent $AGENT_NAME"
