## Work Rules

- Commit scopes: `skills` for `claude/skills/` and `claude/evals/`, otherwise `agents`.
- After changing `agents/claude/skills/<name>/`, run `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/<name>` from the repository root, then run `skill-improver`.
- For suites under `agents/claude/evals/<skill>/`, run `bash agents/claude/skills/waza/scripts/waza-run.sh eval <skill>` (the `waza` skill); never invoke the `waza` CLI directly.

## Configuration Boundaries

- Keep runtime state and secrets outside tracked files.
- `claude/settings.json` is ignored since 2026-10-18 because mods such as `/ultra-config` rewrite it; never `git add` it. The copy to paste on a new machine is the root `README.md` `settings.json` section: update that block when hooks, permissions, env, or `pluginConfigs` change.
- `claude/` is symlinked to `~/.claude`; files inside it must not reference outside the tree with relative paths.
- `claude/` mixes tracked configuration with ignored runtime state. Follow `.gitignore`; write ignored state only when a checked-in hook or workflow owns that path.
- Treat `claude/plugins/` as read-only.
- Add `.gitignore` entries when tools create new runtime files under `claude/`.
- `claude/mcp.json` is empty by default; configure MCP through the Claude Code UI, which writes to `~/.claude.json`.
- `claude/CLAUDE.md` is the user-global instruction file for every Claude Code session. Keep it under 200 lines and sync its Agent Identity with `claude/SOUL.md`.
- Global rules start Claude-only under `claude/`; move a rule up to a shared location only when a second consumer needs it.
- Repository-root `.claude/<type>/` is project-local; `agents/claude/<type>/` is user-global. Put reusable skills under `agents/claude/`.

## Ask First

- Modifying `claude/settings.json` or `claude/mcp.json`.
- Adding a top-level directory under `agents/` (may require dotrc symlinks) or changing `claude/SOUL.md` (its Agent Identity syncs into `claude/CLAUDE.md`).
