# Changelog

Notable changes to this project. Versions follow semver-lite.

## [Unreleased]

### Added
- CI: GitHub Actions — Ubuntu/macOS test matrix including a spaces-in-path checkout leg; shellcheck job (error severity)
- Tests: opt-in leak scan (`LEAK_TOKENS` env / CI secret), denylist coverage for `git checkout --` / `git restore`, spec-docs frontmatter check — suite now 152 assertions
- CONTRIBUTING.md

### Changed
- `harness-default.json` now denies work-discarding git commands (`git checkout -- .`, `git restore`)

### Removed
- Dead code: unused `portable_sha256()` in `install.sh`; redundant GNU/BSD branch in `activate.sh`

## [v0.1.0] — 2026-09-25

Initial public release: 5 steering files, hub agent + 4 least-privilege subagents, 10 skills, memory conventions, install/scaffold/activate scripts, 148 test assertions.
