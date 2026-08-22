## Work Rules

- Work only on `main`; do not create branches or PRs.
- Scopes follow directories: `amp`, `claude`, `codex`, `hooks`, `pi`, `rules`, `skills`.
- The root `gitmessage` and `.githooks/commit-msg` define commit types and subject format.
- After changing `agents/claude/skills/<name>/`, run `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/<name>` from the repository root, then run `skill-improver`.
- For suites under `agents/claude/evals/<skill>/`, follow `agents/claude/agents/waza-runner.md`; never invoke the `waza` CLI directly.
- Edit repository paths, never symlink targets.

## Configuration Boundaries

- `claude/CLAUDE.md`, `claude/settings.json`, `amp/`, `codex/hooks.json`, and `pi/extensions/` affect every local session for their harness. Keep runtime state and secrets outside tracked files.
- `hooks/workflow-hooks.sh` is the canonical cross-harness hook policy. Keep Claude, Codex, Amp, and Pi adapters limited to event and result translation.
- `claude/` is symlinked to `~/.claude`; files inside it must not reference outside the tree with relative paths.
- `claude/` mixes tracked configuration with ignored runtime state. Follow `.gitignore`; write ignored state only when a checked-in hook or workflow owns that path.
- Do not reference or modify `claude/deplicated/`; treat `claude/plugins/` as read-only.
- Add `.gitignore` entries when tools create new runtime files under `claude/`.
- `claude/mcp.json` is empty by default; configure MCP through the Claude Code UI, which writes to `~/.claude.json`.
- `rules/AGENTS.md` is shared by Claude, Amp, Codex, and Pi. Keep it self-contained, harness-neutral, and under 8 KB. Sync its Agent Identity with `rules/SOUL.md`.
- Repository-root `.claude/<type>/` is project-local; `agents/claude/<type>/` is user-global. Put reusable agents and skills under `agents/claude/`.
- Amp loads `~/.claude/skills/` directly, and the Pi extension contributes the same path. Do not duplicate portable skills under harness directories.

## Ask First

- Modifying `claude/settings.json`, `claude/mcp.json`, or `amp/settings.json`.
- Adding a top-level harness directory under `agents/` (may require dotrc symlinks) or changing `rules/SOUL.md` (affects all agents).
