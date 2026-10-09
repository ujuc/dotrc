## Work Rules

- Commit scopes: `skills` for `claude/skills/` and `claude/evals/`, `rules` for `rules/`, otherwise `agents`.
- After changing `agents/claude/skills/<name>/`, run `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/<name>` from the repository root, then run `skill-improver`.
- For suites under `agents/claude/evals/<skill>/`, run `bash agents/claude/skills/waza/scripts/waza-run.sh eval <skill>` (the `waza` skill); never invoke the `waza` CLI directly.

## Configuration Boundaries

- `claude/CLAUDE.md`, `claude/settings.json`, `amp/`, `codex/hooks.json`, `codex/hooks/`, and `pi/agent/extensions/` affect every local session for their harness. Keep runtime state and secrets outside tracked files.
- `workflow-contract.json` is the canonical harness-neutral contract for managed artifact paths, sole writers, archive destinations, maintenance cadence, and Superpowers boundaries. Keep the Rust embedded contract and validator in sync with it. The binary re-serializes the contract, so compare values, not text: if `workflow-hooks contract | jq -S 'del(..|nulls)'` differs from `jq -S . workflow-contract.json`, the installed binary and this file disagree. After an approved contract change, rebuild with `cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"`; otherwise report the mismatch and act on neither version until they match.
- `tools/workflow-hooks/` is the canonical cross-harness hook policy and native Claude/Codex event translator. Install its Rust binary at `~/.local/bin/workflow-hooks`; keep Amp and Pi adapters limited to native event and result translation.
- `hooks/test-workflow-hooks.sh` is the black-box contract suite for the installed policy surface; do not add runtime shell wrappers around the binary.
- `claude/` is symlinked to `~/.claude`; files inside it must not reference outside the tree with relative paths.
- `claude/` mixes tracked configuration with ignored runtime state. Follow `.gitignore`; write ignored state only when a checked-in hook or workflow owns that path.
- Do not reference or modify `claude/deplicated/`; treat `claude/plugins/` as read-only.
- Add `.gitignore` entries when tools create new runtime files under `claude/`.
- `claude/mcp.json` is empty by default; configure MCP through the Claude Code UI, which writes to `~/.claude.json`.
- `rules/AGENTS.md` is shared by Claude, Amp, and Codex. Keep it self-contained, harness-neutral, and under 8 KB. Sync its Agent Identity with `rules/SOUL.md`.
- Repository-root `.claude/<type>/` is project-local; `agents/claude/<type>/` is user-global. Put reusable skills under `agents/claude/`; worker roles live in the owning skill's `references/roles/`.
- Amp loads `~/.claude/skills/` directly, and the Pi extension contributes the same path. Do not duplicate portable skills under harness directories.

## Managed Workflow

- Keep one active workflow per checkout: `spec.md` (architecture-level work only) → optional `.research/research-*.md` → `.plans/plan-*.md` → explicit approval → implementation → durable `docs/{specs,research,plans}/`. Work scoped to `agents/` runs its workflow from `agents/` (archive paths resolve against the working directory) and lands in `agents/docs/`; everything else lands in the repository-root `docs/`.
- Superpowers `writing-plans` is the sole plan writer, at the contract plan path. `implement-plan` is the sole managed executor and archive caller.
- `generate-skills` remains the local authoring controller; TDD, debugging, verification, review, and parallel dispatch remain optional disciplines. Superpowers execution/worktree/branch controllers do not own this workflow.

## Ask First

- Modifying `claude/settings.json`, `claude/mcp.json`, or `amp/settings.json`.
- Adding a top-level harness directory under `agents/` (may require dotrc symlinks) or changing `rules/SOUL.md` (affects all agents).
