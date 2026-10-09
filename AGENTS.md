Dotfiles (zsh, Ghostty, Starship, bat, tig, Zed) plus the shared coding-agent configuration under `agents/` for Claude Code, Codex, Amp and Pi, deployed as symlinks by `scripts/install.sh`.

`agents/rules/AGENTS.md` is the user-global instruction layer Claude, Codex and Amp load (Claude via `agents/claude/CLAUDE.md`, Codex via the `agents/codex/AGENTS.md` symlink, Amp via import; Pi reads only its untracked `~/.pi/agent/AGENTS.md`); project rules live in this file and the nested `AGENTS.md` files under `agents/`.

## Work Rules

- Commit directly to `main`; do not create branches or PRs.
- Scopes: zshrc (including zimrc), agents, zed, scripts, docs, or omit for root changes. Under `agents/`, `agents/AGENTS.md` refines `agents` into `skills` and `rules`.
- `gitmessage` and `.githooks/commit-msg` define commit types and subject format; ask before modifying `gitmessage` because it is used globally.
- Deploy managed dotfiles through `scripts/install.sh` as symlinks, never copies. Ask before adding a link and document its target in `README.md`.
- For `zshrc` or `zimrc` changes, run `zbench`; use `zprofile` to diagnose startup regressions.
- Preserve `zshrc` order: Environment → History → Plugins → Tools → Aliases → Local.
- Keep work-specific config in `~/.zshrc.work`; never track secrets or work-specific paths.

## `agents/` Configuration

- Changes under `agents/claude/`, `agents/codex/`, `agents/amp/`, `agents/pi/`, or `agents/rules/` affect live machine-wide configuration. Edit repository paths, never symlink targets.
