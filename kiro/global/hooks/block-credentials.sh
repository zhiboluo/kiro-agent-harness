#!/bin/sh
# block-credentials.sh — preToolUse hook: blocks tool calls that touch credential paths.
#
# Kiro CLI 2.x contract: hook payload arrives as JSON on stdin;
# exit 2 blocks the tool call and STDERR is returned to the LLM.
# (CLI 3.x moves hooks to standalone .kiro/hooks/*.json files — run
# `kiro-cli agent migrate` when upgrading.)
#
# Patterns are deliberately recall-leaning: a false positive costs the agent
# one visible block message; a false negative leaks a credential.
input=$(cat)
case "$input" in
    *".ssh/"*|*".aws/"*|*".kube/config"*|*"gh/hosts.yml"*|*".docker/config.json"*|\
    *".env"*|*"id_rsa"*|*"id_ed25519"*|*"id_ecdsa"*|*"credentials.json"*)
        echo "BLOCKED by block-credentials hook: tool input references a credential or secret path (.ssh, .aws, .kube/config, gh hosts.yml, docker config, .env, private keys, credentials.json). Reference secrets by key name only — never read or print values." >&2
        exit 2
        ;;
esac
exit 0
