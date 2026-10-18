## Work Rules

- Commit scopes: `skills` for `claude/skills/` and `claude/evals/`, `rules` for `rules/`, otherwise `agents`.
- After changing `agents/claude/skills/<name>/`, run `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/<name>` from the repository root, then run `skill-improver`.
- For suites under `agents/claude/evals/<skill>/`, run `bash agents/claude/skills/waza/scripts/waza-run.sh eval <skill>` (the `waza` skill); never invoke the `waza` CLI directly.

## Configuration Boundaries

- `claude/CLAUDE.md`, `amp/`, `codex/hooks.json`, and `codex/hooks/` affect every local session for their harness. Keep runtime state and secrets outside tracked files.
- `claude/settings.json` is ignored since 2026-10-18 because mods such as `/ultra-config` rewrite it; never `git add` it. The copy to paste on a new machine is the root `README.md` `settings.json` section: update that block when hooks, permissions, env, or `pluginConfigs` change.
- `claude/` is symlinked to `~/.claude`; files inside it must not reference outside the tree with relative paths.
- `claude/` mixes tracked configuration with ignored runtime state. Follow `.gitignore`; write ignored state only when a checked-in hook or workflow owns that path.
- Treat `claude/plugins/` as read-only.
- Add `.gitignore` entries when tools create new runtime files under `claude/`.
- `claude/mcp.json` is empty by default; configure MCP through the Claude Code UI, which writes to `~/.claude.json`.
- `rules/AGENTS.md` is shared by Claude, Amp, and Codex. Keep it self-contained, harness-neutral, and under 8 KB. Sync its Agent Identity with `rules/SOUL.md`.
- Repository-root `.claude/<type>/` is project-local; `agents/claude/<type>/` is user-global. Put reusable skills under `agents/claude/`; worker roles live in the owning skill's `references/roles/`.
- Amp loads `~/.claude/skills/` directly. Do not duplicate portable skills under harness directories.

## Ask First

- Modifying `claude/settings.json`, `claude/mcp.json`, or `amp/settings.json`.
- Adding a top-level harness directory under `agents/` (may require dotrc symlinks) or changing `rules/SOUL.md` (affects all agents).
