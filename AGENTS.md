## Work Rules

- Commit directly to `main`; do not create branches or PRs.
- Scopes: zshrc (including zimrc), agents, zed, scripts, docs, or omit for root changes.
- `gitmessage` defines commit types and subject format; ask before modifying it because it is used globally.
- Deploy root dotfiles with symlinks, never copies. Ask before adding one and document its target in `README.md`.
- For zsh changes run `zbench`; use `zprofile` for diagnosis.
- Preserve `zshrc` order: Environment → History → Plugins → Tools → Aliases → Local.
- Keep work-specific config in `~/.zshrc.work`; never track secrets or work-specific paths.

## `agents/` Submodule

- `agents/` is an independent repository; ask before modifying its contents.
- Changes under `agents/claude/`, `agents/amp/`, or `agents/rules/` affect live machine-wide configuration. Edit repository paths, never symlink targets.
- Check `git -C agents status`; commit and push there before updating the parent pointer.
