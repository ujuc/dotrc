Dotfiles (zsh, Ghostty, Starship, bat, tig, Zed) plus the Claude Code configuration under `agents/`, deployed as symlinks by `scripts/install.sh`.

`agents/claude/AGENTS.global.md` is the shared user-global instruction layer, linked to `~/.codex/AGENTS.md`, `~/.omp/agent/AGENTS.md` and `~/.pi/agent/AGENTS.md` and imported by `agents/claude/CLAUDE.md` (`~/.claude/CLAUDE.md`), which keeps only Claude-only rules. Project rules live in this file and the nested `AGENTS.md` files under `agents/`; each has a sibling `CLAUDE.md` that imports it.

## Work Rules

- Commit directly to `main`; do not create branches or PRs.
- Scopes: zshrc (including zimrc), agents, zed, scripts, docs, or omit for root changes. Under `agents/`, `agents/AGENTS.md` refines `agents` into `skills`.
- `gitmessage` and `.githooks/commit-msg` define commit types and subject format. The hook only runs after `install.sh --cli` has set `core.hooksPath .githooks`, so check `git config core.hooksPath` on a fresh clone. Ask before modifying `gitmessage` because it is used globally.
- Deploy managed dotfiles through `scripts/install.sh` as symlinks, never copies. It is a thin launcher that builds and runs the Rust installer in `scripts/installer/`; change behavior there, not in the launcher. The link list is `Layout::selected_links` in `scripts/installer/src/links.rs`, and its preflight aborts the whole run before any step when a destination conflicts. Ask before adding a link and document its target in `README.md`.
- `zshrc` exports `DOTRCDIR` and `DOTRC_AGENTS_DIR`; scripts and skills locate the repository through them with the fallback `${XDG_CONFIG_HOME:-$HOME/.config}/dotrc`. Keep that fallback in new scripts instead of hardcoding the path.
- There is no root test suite. For installer changes, run `cargo test` and `cargo clippy --all-targets -- -D warnings` in `scripts/installer/`. For `zshrc` or `zimrc` changes, run `zbench` and use `zprofile` to diagnose startup regressions; skill, launcher and eval checks are listed in `agents/AGENTS.md`.
- Preserve `zshrc` order: Environment → History → Plugins → Tools → Aliases → Local.
- Keep work-specific config in `~/.zshrc.work`; never track secrets or work-specific paths.

## `agents/` Configuration

- Changes under `agents/claude/` affect live machine-wide configuration. Edit repository paths, never symlink targets.
