## Work Rules

- Work only on `main`; do not create branches or PRs.
- Scopes follow directories: `amp`, `claude`, `rules`, `skills`.
- The root `gitmessage` and `.githooks/commit-msg` define commit types and subject format.
- After changing a skill, run `bash claude/skills/generate-skills/scripts/validate-skill claude/skills/<name>` and `skill-improver`.
- Run suites under `claude/evals/<skill>/` with `waza-runner`, never the `waza` CLI.
- Edit repository paths, never symlink targets.

## Configuration Boundaries

- `claude/CLAUDE.md`, `claude/settings.json`, `amp/AGENTS.md`, and `amp/settings.json` affect every local Claude or Amp session. Keep runtime state and secrets outside tracked files.
- `claude/` is symlinked to `~/.claude`; files inside it must not reference outside the tree with relative paths.
- `claude/` mixes tracked configuration with ignored runtime state. Follow `.gitignore`; only auto-memory under `claude/projects/` is writable.
- Do not reference or modify `claude/deplicated/`; treat `claude/plugins/` as read-only.
- Add `.gitignore` entries when tools create new runtime files under `claude/`.
- `claude/mcp.json` is empty by default; configure MCP through the Claude Code UI, which writes to `~/.claude.json`.
- `rules/AGENTS.md` is shared by Claude, Amp, and Codex. Keep it self-contained, harness-neutral, and under 8 KB. Sync its Agent Identity with `rules/SOUL.md`.
- `.claude/<type>/` is repo-only; `claude/<type>/` is global. Put reusable agents and skills under `claude/`.
- Amp loads `~/.claude/skills/`; do not duplicate portable skills under `amp/`.

## Ask First

- Modifying `claude/settings.json`, `claude/mcp.json`, or `amp/settings.json`.
- Adding agent directories (may require dotrc symlinks) or changing `rules/SOUL.md` (affects all agents).
