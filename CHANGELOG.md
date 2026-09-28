# Changelog

Notable changes to this project. Versions follow semver-lite.

## [Unreleased]

### Added
- CI: GitHub Actions — Ubuntu/macOS test matrix including a spaces-in-path checkout leg; shellcheck job (error severity)
- Tests: opt-in leak scan (`LEAK_TOKENS` env / CI secret), denylist coverage for `git checkout --` / `git restore`, spec-docs frontmatter check, behavioral tests for the credential hook — suite now 162 assertions
- Security: `preToolUse` credential-blocking hook (`hooks/block-credentials.sh`) on all 5 agents and the project template — exit 2 blocks tool calls touching `.ssh`/`.aws`/`.kube/config`/`.env`/private keys per the Kiro CLI 2.x hook contract; deployed by `install.sh`
- CONTRIBUTING.md

### Changed
- `harness-default.json` now denies work-discarding git commands (`git checkout -- .`, `git restore`)
- README documents the upstream policy: this repo is upstream; machine-local state (memory, extra skills, settings) is never committed back

### Removed
- Dead code: unused `portable_sha256()` in `install.sh`; redundant GNU/BSD branch in `activate.sh`

## [v0.1.0] — 2026-09-25

Initial public release: 5 steering files, hub agent + 4 least-privilege subagents, 10 skills, memory conventions, install/scaffold/activate scripts, 148 test assertions.
