---
name: dotrc
description: Personal macOS development environment configuration
standard: agents.md/v1
---

## Project Overview

Personal macOS development environment configuration repository. Deployed via symlinks from `$XDG_CONFIG_HOME/dotrc` to each tool's expected location.

## Operational Gotchas

- `agents/` is an independent git submodule (`ujuc/agent-stuff`) with its own CLAUDE.md — always commit and push inside `agents/` first, then update the parent pointer
- Adding new dotfiles requires documenting the symlink target in README.md
- `~/.zshrc.work` lives outside the repository (untracked) — work-specific config goes there, never in tracked files

## Non-Obvious Conventions

- `zshrc` has a strict section order: Environment → History → Plugins → Tools → Aliases → Local — preserve this when editing
- Commit rules (types, scopes, `-하다` format) are defined in root `CLAUDE.md` and the `gitmessage` template — do not duplicate here

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
