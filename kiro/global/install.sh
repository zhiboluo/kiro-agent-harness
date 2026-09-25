#!/bin/bash
# install.sh — Deploy harness global configs to ~/.kiro/
#
# Usage:
#   bash kiro/global/install.sh          # from repo root
#   bash install.sh                       # from kiro/global/
#
# What it does:
#   - Copies steering, agents, skills, and memory to ~/.kiro/
#   - Does NOT overwrite existing files (use --force to overwrite)
#   - Updates absolute paths in agent configs to match the current user's home
#   - Reports what was installed
#
set -uo pipefail

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$SCRIPT_DIR"

# Check we're in the right place
if [ ! -d "$GLOBAL_DIR/steering" ] || [ ! -d "$GLOBAL_DIR/agents" ]; then
    echo "ERROR: Run this script from kiro/global/ or as 'bash kiro/global/install.sh' from repo root."
    exit 1
fi

FORCE=false
if [ "${1:-}" = "--force" ]; then
    FORCE=true
    echo "Force mode: existing files will be overwritten."
fi

KIRO_DIR="$HOME/.kiro"
INSTALLED=0
SKIPPED=0

install_file() {
    local src="$1"
    local dst="$2"
    
    mkdir -p "$(dirname "$dst")"
    
    if [ -f "$dst" ] && [ "$FORCE" = false ]; then
        echo "  SKIP $dst (exists, use --force to overwrite)"
        ((SKIPPED++))
    else
        cp "$src" "$dst"
        echo "  ✓ $dst"
        ((INSTALLED++))
    fi
}

echo "Installing harness to $KIRO_DIR ..."
echo ""

# Steering
echo "Steering files:"
for f in "$GLOBAL_DIR"/steering/*.md; do
    name=$(basename "$f")
    install_file "$f" "$KIRO_DIR/steering/$name"
done
echo ""

# Agents
echo "Agent configs:"
for f in "$GLOBAL_DIR"/agents/*.json; do
    name=$(basename "$f")
    install_file "$f" "$KIRO_DIR/agents/$name"
done
echo ""

# Agent prompts
echo "Agent prompts:"
for f in "$GLOBAL_DIR"/agents/prompts/*.md; do
    name=$(basename "$f")
    install_file "$f" "$KIRO_DIR/agents/prompts/$name"
done
echo ""

# Skills
echo "Skills:"
for d in "$GLOBAL_DIR"/skills/*/; do
    skill_name=$(basename "$d")
    install_file "$d/SKILL.md" "$KIRO_DIR/skills/$skill_name/SKILL.md"
done
echo ""

# Memory (seed — only if memory dir doesn't have entries yet)
echo "Memory:"
install_file "$GLOBAL_DIR/memory/INDEX.md" "$KIRO_DIR/memory/INDEX.md"
for f in "$GLOBAL_DIR"/memory/decisions/*.md; do
    name=$(basename "$f")
    install_file "$f" "$KIRO_DIR/memory/decisions/$name"
done
for f in "$GLOBAL_DIR"/memory/patterns/*.md; do
    name=$(basename "$f")
    install_file "$f" "$KIRO_DIR/memory/patterns/$name"
done
echo ""

# Portable in-place sed (GNU vs BSD)
portable_sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Portable sha256 (GNU sha256sum vs BSD shasum)
portable_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum
    else
        shasum -a 256
    fi
}

# Fix paths in agent configs to match current user
echo "Updating paths for current user ($USER @ $HOME)..."
for f in "$KIRO_DIR/agents/harness-default.json"; do
    if [ -f "$f" ]; then
        # Fix file:// tilde paths (tilde doesn't expand for file:// URIs)
        portable_sed_i "s|file://~/|file://$HOME/|g" "$f"
        # Fix prompt file:// tilde path
        portable_sed_i "s|file://~/.kiro|file://$HOME/.kiro|g" "$f"
        echo "  ✓ Updated paths in $(basename "$f")"
    fi
done
echo ""

echo "Done: $INSTALLED installed, $SKIPPED skipped."
echo ""
echo "Next steps:"
echo "  1. Review ~/.kiro/steering/AGENTS.md and update canary/preferences"
echo "  2. Set default agent (optional): kiro-cli agent set-default harness-default"
echo "  3. If using the harness-engineering project: cd kiro && bash activate.sh"
echo "  4. Test: kiro-cli chat"
