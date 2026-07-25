---
name: dotrc
description: Personal macOS development environment configuration
standard: agents.md/v1
---

## Project Overview

Personal macOS development environment configuration repository. Deployed via symlinks from `$XDG_CONFIG_HOME/dotrc` to each tool's expected location.

## Work Rules

- Commit directly to `main` — no branches, no PRs
- **Scopes**: zshrc (incl. zimrc), agents, zed, scripts, docs, or omit for root-level changes
- Subject format and the authoritative type list live in the `gitmessage` template — do not restate them here

## Verification

There is no build or test suite. For `zshrc`, `zimrc`, or plugin changes the verification loop is shell startup timing:

- `zbench` (`scripts/benchmark.sh`) — startup time over N runs; uses hyperfine when installed
- `zprofile` (`scripts/profile-startup.zsh`) — per-module timing via `zprof`

## Operational Gotchas

- `.githooks/commit-msg` rejects any subject not ending in the literal `하다` — verbs like `걷어내다` or `드러내다` fail. It applies only where `core.hooksPath` is set, which README configures for both this repo and `agents/`
- `agents/` is an independent git submodule (`ujuc/agent-stuff`) with its own agent docs and commit workflow — always commit and push inside `agents/` first, then update the parent pointer
- `agents/` holds the live global agent configuration for this machine: `agents/claude/` → `~/.claude`, and `agents/rules/AGENTS.md` → `~/.codex/AGENTS.md` and `~/.config/amp/AGENTS.md`. Editing those paths changes the configuration of the session doing the editing — always edit here, never at the symlink target
- The two repositories use different remote protocols — parent is SSH (`git@github.com:ujuc/dotrc.git`), submodule is HTTPS — so a submodule push can succeed while the parent push fails on a missing SSH key
- Adding new dotfiles requires documenting the symlink target in README.md
- `~/.zshrc.work` lives outside the repository (untracked) — work-specific config goes there, never in tracked files

## Non-Obvious Conventions

- `zshrc` has a strict section order: Environment → History → Plugins → Tools → Aliases → Local — preserve this when editing

## Boundaries

### Always Do

- Use symlinks for deployment, never copy files
- Check submodule status separately: `git -C agents status`

### Ask First

- Adding new dotfiles (needs symlink setup documentation in README.md)
- Modifying `gitmessage` template (affects all git commits globally)
- Changes to `agents/` submodule content (has its own repository and workflow)

### Never Do

- Track secrets, tokens, or work-specific paths in this repository
- Modify files in `agents/` without committing in the submodule first
