## Work Rules

- Commit directly to `main`; do not create branches or PRs.
- Scopes: zshrc (including zimrc), agents, zed, scripts, docs, or omit for root changes.
- `gitmessage` and `.githooks/commit-msg` define commit types and subject format; ask before modifying `gitmessage` because it is used globally.
- Deploy managed dotfiles through `scripts/install.sh` as symlinks, never copies. Ask before adding a link and document its target in `README.md`.
- For `zshrc` or `zimrc` changes, run `zbench`; use `zprofile` to diagnose startup regressions.
- Preserve `zshrc` order: Environment → History → Plugins → Tools → Aliases → Local.
- Keep work-specific config in `~/.zshrc.work`; never track secrets or work-specific paths.

## `agents/` Configuration

- Changes under `agents/claude/`, `agents/amp/`, or `agents/rules/` affect live machine-wide configuration. Edit repository paths, never symlink targets.
