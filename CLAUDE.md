Dotfiles (zsh, Ghostty, Starship, bat, tig, Zed) plus the Claude Code configuration under `agents/`, deployed as symlinks by `scripts/install.sh`.

`agents/claude/CLAUDE.md` is the user-global instruction layer (`~/.claude/CLAUDE.md`); project rules live in this file and the nested `CLAUDE.md` files under `agents/`.

## Work Rules

- Commit directly to `main`; do not create branches or PRs.
- Scopes: zshrc (including zimrc), agents, zed, scripts, docs, or omit for root changes. Under `agents/`, `agents/CLAUDE.md` refines `agents` into `skills`.
- `gitmessage` and `.githooks/commit-msg` define commit types and subject format. The hook only runs after `install.sh --cli` has set `core.hooksPath .githooks`, so check `git config core.hooksPath` on a fresh clone. Ask before modifying `gitmessage` because it is used globally.
- Deploy managed dotfiles through `scripts/install.sh` as symlinks, never copies. The link list is `visit_static_selected_links`, and its preflight aborts the whole run before any step when a destination conflicts. Ask before adding a link and document its target in `README.md`.
- `zshrc` exports `DOTRCDIR` and `DOTRC_AGENTS_DIR`; scripts and skills locate the repository through them with the fallback `${XDG_CONFIG_HOME:-$HOME/.config}/dotrc`. Keep that fallback in new scripts instead of hardcoding the path.
- There is no root test suite. For `zshrc` or `zimrc` changes, run `zbench` and use `zprofile` to diagnose startup regressions; skill, launcher and eval checks are listed in `agents/CLAUDE.md`.
- Preserve `zshrc` order: Environment → History → Plugins → Tools → Aliases → Local.
- Keep work-specific config in `~/.zshrc.work`; never track secrets or work-specific paths.

## `agents/` Configuration

- Changes under `agents/claude/` affect live machine-wide configuration. Edit repository paths, never symlink targets.
